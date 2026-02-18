<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Customer;
use App\Models\DeviceToken;
use App\Models\User;
use App\Notifications\GeneralNotification;
use App\Services\PushNotificationService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Notification as NotificationFacade;
use Illuminate\Support\Facades\Validator;

class AdminNotificationController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $admin = $request->user();

        $notifications = $admin->notifications()
            ->orderBy('created_at', 'desc')
            ->paginate(20);

        return response()->json([
            'success' => true,
            'data' => [
                'notifications' => $notifications,
                'unread_count' => $admin->unreadNotifications()->count(),
            ],
        ]);
    }

    public function markRead(Request $request, string $id): JsonResponse
    {
        $admin = $request->user();
        $notification = $admin->notifications()->where('id', $id)->first();

        if (!$notification) {
            return response()->json([
                'success' => false,
                'message' => 'Notification not found',
            ], 404);
        }

        $notification->markAsRead();

        return response()->json([
            'success' => true,
            'message' => 'Notification marked as read',
        ]);
    }

    public function send(Request $request, PushNotificationService $push): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'title' => 'required|string|max:255',
            'body' => 'required|string|max:1000',
            'type' => 'nullable|string|max:50',
            'send_to' => 'nullable|string|in:customers,admins,both',
            'customer_ids' => 'nullable|array',
            'customer_ids.*' => 'integer|exists:customers,id',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors(),
            ], 422);
        }

        $data = $validator->validated();
        $sendTo = $data['send_to'] ?? 'customers';
        $type = $data['type'] ?? 'general';

        $notification = new GeneralNotification($data['title'], $data['body'], $type);

        $targets = collect();
        $customers = collect();
        $admins = collect();
        if ($sendTo === 'customers' || $sendTo === 'both') {
            $customers = empty($data['customer_ids'])
                ? Customer::query()->where('is_active', true)->get()
                : Customer::query()->whereIn('id', $data['customer_ids'])->get();
            $targets = $targets->merge($customers);
        }

        if ($sendTo === 'admins' || $sendTo === 'both') {
            $admins = User::query()->get();
            $targets = $targets->merge($admins);
        }

        if ($targets->isNotEmpty()) {
            NotificationFacade::send($targets, $notification);
        }

        $tokens = collect();
        if ($customers->isNotEmpty()) {
            $tokens = $tokens->merge(
                DeviceToken::query()
                    ->where('notifiable_type', Customer::class)
                    ->whereIn('notifiable_id', $customers->pluck('id'))
                    ->pluck('token')
            );
        }
        if ($admins->isNotEmpty()) {
            $tokens = $tokens->merge(
                DeviceToken::query()
                    ->where('notifiable_type', User::class)
                    ->whereIn('notifiable_id', $admins->pluck('id'))
                    ->pluck('token')
            );
        }

        $push->send($tokens->unique()->values()->all(), $data['title'], $data['body'], ['type' => $type]);

        return response()->json([
            'success' => true,
            'message' => 'Notification sent',
        ]);
    }

    public function registerDevice(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'token' => 'required|string|max:500',
            'platform' => 'nullable|string|in:ios,android,web',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors(),
            ], 422);
        }

        $admin = $request->user();
        $data = $validator->validated();

        $device = DeviceToken::firstOrNew(['token' => $data['token']]);
        $device->platform = $data['platform'] ?? $device->platform;
        $device->last_used_at = now();
        $device->notifiable()->associate($admin);
        $device->save();

        return response()->json([
            'success' => true,
            'message' => 'Device token registered',
        ]);
    }
}
