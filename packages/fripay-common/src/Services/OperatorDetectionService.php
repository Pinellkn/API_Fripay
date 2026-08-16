<?php

namespace App\Services;

use App\Models\Operator;
use App\Models\PhonePrefix;

class OperatorDetectionService
{
    /**
     * Detect the operator for a given phone number based on its prefix.
     */
    public function detect(string $phoneNumber): ?Operator
    {
        $phoneNumber = ltrim($phoneNumber, '+');
        
        // Try prefixes from longest to shortest for best match
        $prefixes = PhonePrefix::with('operator')
            ->orderByRaw('LENGTH(prefix) DESC')
            ->get();

        foreach ($prefixes as $prefixEntry) {
            if (str_starts_with($phoneNumber, $prefixEntry->prefix)) {
                return $prefixEntry->operator;
            }
        }

        return null;
    }

    /**
     * Normalize phone number to E.164 format.
     */
    public function normalize(string $phoneNumber): string
    {
        $phoneNumber = preg_replace('/[^\d+]/', '', $phoneNumber);
        
        if (!str_starts_with($phoneNumber, '+')) {
            $phoneNumber = '+229' . ltrim($phoneNumber, '0');
        }
        
        return $phoneNumber;
    }

    /**
     * Validate E.164 format.
     */
    public function isValidE164(string $phoneNumber): bool
    {
        return (bool) preg_match('/^\+229\d{8}$/', $phoneNumber);
    }
}
