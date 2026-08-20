<?php

namespace App\Http\Requests\Transfer;

use Illuminate\Foundation\Http\FormRequest;

class QuoteRequest extends AppHttpRequestsBaseApiRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'sender_account_id' => ['required', 'string', 'uuid', 'exists:linked_accounts,id'],
            'recipient_phone' => ['required', 'string', 'regex:/^\+229\d{8}$/'],
            'amount' => ['required', 'numeric', 'min:100', 'max:5000000'],
        ];
    }

    public function messages(): array
    {
        return [
            'amount.min' => 'Le montant minimum est de 100 XOF.',
            'amount.max' => 'Le montant maximum est de 5 000 000 XOF.',
        ];
    }
}
