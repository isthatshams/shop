<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\CustomerSetting;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class CustomerSettingsController extends Controller
{
    public function show(Request $request): JsonResponse
    {
        $customer = $request->user();

        $settings = $customer->settings;
        if (!$settings) {
            $settings = $customer->settings()->create([
                'language' => 'en',
                'theme' => 'system',
                'notifications_enabled' => true,
                'addresses' => [],
                'payment_methods' => [],
            ]);
        }

        return response()->json([
            'success' => true,
            'data' => [
                'profile' => [
                    'name' => $customer->name,
                    'email' => $customer->email,
                    'phone' => $customer->phone,
                    'avatar' => $customer->avatar,
                ],
                'settings' => [
                    'language' => $settings->language,
                    'theme' => $settings->theme,
                    'notifications_enabled' => $settings->notifications_enabled,
                    'addresses' => $settings->addresses ?? [],
                    'payment_methods' => $settings->payment_methods ?? [],
                ],
            ],
        ]);
    }

    public function update(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'profile' => 'sometimes|array',
            'profile.name' => 'sometimes|string|max:255',
            'profile.phone' => 'sometimes|nullable|string|max:30',
            'profile.avatar' => 'sometimes|nullable|url',
            'settings' => 'sometimes|array',
            'settings.language' => 'sometimes|string|in:en,ar',
            'settings.theme' => 'sometimes|string|in:light,dark,system',
            'settings.notifications_enabled' => 'sometimes|boolean',
            'settings.addresses' => 'sometimes|array',
            'settings.addresses.*.label' => 'required_with:settings.addresses|string|max:50',
            'settings.addresses.*.line1' => 'required_with:settings.addresses|string|max:255',
            'settings.addresses.*.line2' => 'nullable|string|max:255',
            'settings.addresses.*.city' => 'required_with:settings.addresses|string|max:100',
            'settings.addresses.*.state' => 'nullable|string|max:100',
            'settings.addresses.*.zip' => 'nullable|string|max:20',
            'settings.addresses.*.country' => 'required_with:settings.addresses|string|max:100',
            'settings.addresses.*.is_default' => 'nullable|boolean',
            'settings.payment_methods' => 'sometimes|array',
            'settings.payment_methods.*.brand' => 'required_with:settings.payment_methods|string|max:50',
            'settings.payment_methods.*.last4' => 'required_with:settings.payment_methods|string|max:4',
            'settings.payment_methods.*.exp_month' => 'required_with:settings.payment_methods|integer|min:1|max:12',
            'settings.payment_methods.*.exp_year' => 'required_with:settings.payment_methods|integer|min:2020|max:2100',
            'settings.payment_methods.*.is_default' => 'nullable|boolean',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors(),
            ], 422);
        }

        $customer = $request->user();
        $data = $validator->validated();

        if (!empty($data['profile'])) {
            $customer->fill($data['profile']);
            $customer->save();
        }

        if (!empty($data['settings'])) {
            $settings = $customer->settings ?: new CustomerSetting(['customer_id' => $customer->id]);
            $settings->fill($data['settings']);
            $settings->customer_id = $customer->id;
            $settings->save();
        }

        return $this->show($request);
    }
}
