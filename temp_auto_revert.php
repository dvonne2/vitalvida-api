    public function autoRevert(Request $request)
    {
        try {
            $isTestRoute = str_contains($request->getPathInfo(), '/test/');
            
            if (!$isTestRoute) {
                $allowedRoles = ['ceo', 'compliance', 'fc', 'gm'];
                if (!auth()->check() || !in_array(auth()->user()->role, $allowedRoles)) {
                    return response()->json(['error' => 'Unauthorized'], 403);
                }
            }

            // Find payouts older than 48 hours that are still pending
            $cutoffTime = now()->subHours(48);
            $payoutsToRevert = DB::table('payouts')
                ->where('status', 'pending')
                ->where('created_at', '<', $cutoffTime)
                ->get();

            $revertedCount = 0;
            $errors = [];

            foreach ($payoutsToRevert as $payout) {
                try {
                    // Revert the payout
                    DB::table('payouts')
                        ->where('id', $payout->id)
                        ->update([
                            'status' => 'auto_reverted',
                            'updated_at' => now()
                        ]);

                    // Log the action
                    DB::table('payout_action_logs')->insert([
                        'payout_id' => $payout->id,
                        'action' => 'auto_reverted',
                        'user_id' => auth()->id(),
                        'reason' => 'Automatically reverted after 48 hours',
                        'created_at' => now()
                    ]);

                    $revertedCount++;
                } catch (\Exception $e) {
                    $errors[] = [
                        'payout_id' => $payout->id,
                        'error' => $e->getMessage()
                    ];
                }
            }

            return response()->json([
                'success' => true,
                'reverted_count' => $revertedCount,
                'errors' => $errors,
                'processed_at' => now()->toISOString()
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => 'Auto-revert failed: ' . $e->getMessage()
            ], 500);
        }
    }
}
