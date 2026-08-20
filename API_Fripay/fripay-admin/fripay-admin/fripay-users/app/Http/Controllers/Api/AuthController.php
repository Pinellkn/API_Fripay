<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\LoginRequest;
use App\Http\Requests\Auth\RegisterRequest;
use App\Http\Requests\Auth\SetPinRequest;
use App\Http\Requests\Auth\VerifyOtpRequest;
use App\Http\Resources\UserResource;
use App\Models\User;
use App\Services\AuthService;
use App\Services\OperatorDetectionService;
use App\Services\OtpService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AuthController extends Controller
{
    public function __construct(
        private readonly AuthService $authService,
        private readonly OtpService $otpService,
        private readonly OperatorDetectionService $operatorDetection,
    ) {}

    /**
     * POST /api/v1/auth/register
     */
    public function register(RegisterRequest $request): JsonResponse
    {
        $data = $request->validated();
        $phoneNumber = $this->operatorDetection->normalize($data['phone_number']);

        if (!$this->operatorDetection->detect($phoneNumber)) {
            return $this->errorResponse(
                'OPERATOR_NOT_SUPPORTED',
                'Opérateur non supporté',
                422,
                'Ce numéro n\'est pas associé à un opérateur pris en charge.',
                $request
            );
        }

        $user = $this->authService->register([
            'phone_number' => $phoneNumber,
            'first_name' => $data['first_name'] ?? null,
            'last_name' => $data['last_name'] ?? null,
        ]);

        $otp = $this->otpService->generate($phoneNumber, 'registration');

        return response()->json([
            'user_id' => $user->id,
            'phone_number' => $phoneNumber,
            'otp_expires_in' => $otp['expires_in'],
        ], 201);
    }

    /**
     * POST /api/v1/auth/verify-otp
     */
    public function verifyOtp(VerifyOtpRequest $request): JsonResponse
    {
        $data = $request->validated();
        $phoneNumber = $this->operatorDetection->normalize($data['phone_number']);

        if ($this->otpService->isRateLimited($phoneNumber)) {
            return $this->errorResponse(
                'TOO_MANY_ATTEMPTS',
                'Trop de tentatives',
                429,
                'Trop de demandes de code. Veuillez réessayer plus tard.',
                $request
            );
        }

        $valid = $this->otpService->verify($phoneNumber, $data['code'], $data['purpose']);

        if (!$valid) {
            return $this->errorResponse(
                'OTP_INVALID',
                'Code invalide',
                400,
                'Le code de vérification est invalide ou a expiré.',
                $request
            );
        }

        $user = User::where('phone_number', $phoneNumber)->first();
        $tokens = $this->authService->issueTokens($user, [
            'device' => $request->userAgent(),
            'ip' => $request->ip(),
        ]);

        return response()->json($tokens);
    }

    /**
     * POST /api/v1/auth/login
     */
    public function login(LoginRequest $request): JsonResponse
    {
        $data = $request->validated();
        $phoneNumber = $this->operatorDetection->normalize($data['phone_number']);

        $user = User::where('phone_number', $phoneNumber)->first();

        if (!$user) {
            return $this->errorResponse(
                'INVALID_CREDENTIALS',
                'Identifiants invalides',
                401,
                'Numéro de téléphone ou PIN incorrect.',
                $request
            );
        }

        if ($user->status === 'blocked') {
            return $this->errorResponse(
                'ACCOUNT_BLOCKED',
                'Compte bloqué',
                423,
                'Votre compte a été bloqué. Contactez le support.',
                $request
            );
        }

        if (!$this->authService->verifyPin($user, $data['pin'])) {
            return $this->errorResponse(
                'INVALID_CREDENTIALS',
                'Identifiants invalides',
                401,
                'Numéro de téléphone ou PIN incorrect.',
                $request
            );
        }

        $tokens = $this->authService->issueTokens($user, [
            'device' => $request->userAgent(),
            'ip' => $request->ip(),
        ]);

        return response()->json($tokens);
    }

    /**
     * POST /api/v1/auth/refresh-token
     */
    public function refreshToken(Request $request): JsonResponse
    {
        $data = $request->validate(['refresh_token' => 'required|string']);

        $tokens = $this->authService->refreshTokens($data['refresh_token']);

        if (!$tokens) {
            return $this->errorResponse(
                'INVALID_REFRESH_TOKEN',
                'Token de rafraîchissement invalide',
                401,
                'Le token de rafraîchissement est invalide ou a expiré.',
                $request
            );
        }

        return response()->json($tokens);
    }

    /**
     * POST /api/v1/auth/logout
     */
    public function logout(Request $request): JsonResponse
    {
        $this->authService->logout($request->user());
        return response()->json(null, 204);
    }
}
