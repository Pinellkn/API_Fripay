<?php

namespace App\Http\Requests\Transfer;

use Illuminate\Foundation\Http\FormRequest;

class InitiateTransferRequest extends AppHttpRequestsBaseApiRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'quote_token' => ['required', 'string', 'size:32'],
            'sender_account_id' => ['required', 'string', 'uuid', 'exists:linked_accounts,id'],
            'recipient_phone' => ['required', 'string', 'regex:/^\+229\d{8}$/'],
            'amount' => ['required', 'numeric', 'min:100'],
            'pin' => ['required', 'string', 'size:4'],
        ];
    }
}
