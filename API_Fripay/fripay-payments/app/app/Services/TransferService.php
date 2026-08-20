<?php

namespace App\Services;

use App\Models\Transaction;
use App\Models\TransactionStatusHistory;
use Illuminate\Support\Str;

class TransferService
{
    /**
     * Calculate a quote for a potential transfer.
     */
    public function calculateQuote(string $senderAccountId, string $recipientPhone, float $amount): array
    {
        $operatorDetection = app(OperatorDetectionService::class);
        $recipientOperator = $operatorDetection->detect($recipientPhone);

        if (!$recipientOperator) {
            throw new \RuntimeException('OPERATOR_NOT_SUPPORTED');
        }

        $feeAmount = $amount * 0.015;
        if ($feeAmount < 50) $feeAmount = 50;
        if ($feeAmount > 5000) $feeAmount = 5000;

        $quoteToken = Str::random(32);

        cache()->put('quote_' . $quoteToken, [
            'sender_account_id' => $senderAccountId,
            'recipient_phone' => $recipientPhone,
            'amount' => $amount,
            'fee_amount' => $feeAmount,
            'total_debited' => $amount + $feeAmount,
            'recipient_operator_id' => $recipientOperator->id,
            'expires_at' => now()->addMinutes(2),
        ], 180);

        return [
            'recipient_operator' => $recipientOperator->code,
            'recipient_name' => null,
            'amount' => $amount,
            'fee_amount' => $feeAmount,
            'total_debited' => $amount + $feeAmount,
            'rail' => 'aggregator',
            'estimated_delivery_seconds' => 30,
            'quote_token' => $quoteToken,
        ];
    }

    /**
     * Initiate a transfer.
     */
    public function initiate(string $quoteToken, string $senderAccountId, string $recipientPhone, float $amount): Transaction
    {
        $quote = cache()->get('quote_' . $quoteToken);

        if (!$quote) {
            throw new \RuntimeException('QUOTE_EXPIRED');
        }

        if ($quote['expires_at'] < now()) {
            cache()->forget('quote_' . $quoteToken);
            throw new \RuntimeException('QUOTE_EXPIRED');
        }

        if ($quote['sender_account_id'] !== $senderAccountId ||
            $quote['recipient_phone'] !== $recipientPhone ||
            $quote['amount'] != $amount) {
            throw new \RuntimeException('QUOTE_MISMATCH');
        }

        cache()->forget('quote_' . $quoteToken);

        $reference = 'TXN-' . now()->format('Ymd') . '-' . strtoupper(Str::random(6));

        $transaction = Transaction::create([
            'reference' => $reference,
            'idempotency_key' => request()->header('Idempotency-Key', Str::uuid()),
            'sender_user_id' => auth()->id(),
            'sender_account_id' => $senderAccountId,
            'recipient_phone' => $recipientPhone,
            'recipient_operator_id' => $quote['recipient_operator_id'] ?? 1,
            'amount' => $amount,
            'currency' => 'XOF',
            'fee_amount' => $quote['fee_amount'],
            'total_debited' => $quote['total_debited'],
            'rail_used' => 'aggregator',
            'status' => 'processing',
            'client_type_snapshot' => auth()->user()->client_type,
            'initiated_at' => now(),
        ]);

        TransactionStatusHistory::create([
            'transaction_id' => $transaction->id,
            'previous_status' => null,
            'new_status' => 'processing',
            'source' => 'system',
            'note' => 'Transfert initié',
        ]);

        return $transaction;
    }

    /**
     * Cancel a transaction if possible.
     */
    public function cancel(Transaction $transaction): Transaction
    {
        if (!in_array($transaction->status, ['initiated', 'pending'])) {
            throw new \RuntimeException('TRANSACTION_NOT_CANCELLABLE');
        }

        $transaction->update(['status' => 'cancelled']);

        TransactionStatusHistory::create([
            'transaction_id' => $transaction->id,
            'previous_status' => $transaction->status,
            'new_status' => 'cancelled',
            'source' => 'user',
            'note' => 'Annulé par l\'utilisateur',
        ]);

        return $transaction;
    }
}
