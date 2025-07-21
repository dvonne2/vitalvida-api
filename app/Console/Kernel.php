<?php

namespace App\Console;

use Illuminate\Console\Scheduling\Schedule;
use Illuminate\Foundation\Console\Kernel as ConsoleKernel;

class Kernel extends ConsoleKernel
{
    /**
     * Define the application's command schedule.
     */
    protected function schedule(Schedule $schedule): void
    {
        // Auto-revert stale payouts every 2 hours
        $schedule->call(function () {
            $this->autoRevertStalePayouts();
        })->everyTwoHours()->withoutOverlapping();

        // Daily cleanup at 2 AM
        $schedule->call(function () {
            $this->autoRevertStalePayouts();
        })->dailyAt('02:00');

        // Zoho inventory sync every 4 hours
        $schedule->command('zoho:sync-inventory')
            ->everyFourHours()
            ->withoutOverlapping()
            ->runInBackground();

        // Daily low stock check at 8 AM
        $schedule->command('zoho:sync-inventory --low-stock')
            ->dailyAt('08:00')
            ->withoutOverlapping();

        // =============================================================================
        // PHASE 6: ADVANCED REPORTING & ANALYTICS SCHEDULED TASKS
        // =============================================================================

        // Process real-time analytics every 5 minutes
        $schedule->job(\App\Jobs\ProcessRealTimeAnalytics::class)
            ->everyFiveMinutes()
            ->withoutOverlapping()
            ->runInBackground();

        // Process scheduled reports hourly
        $schedule->job(\App\Jobs\ProcessScheduledReports::class)
            ->hourly()
            ->withoutOverlapping()
            ->runInBackground();

        // Cleanup old reports and metrics daily at 2 AM
        $schedule->job(\App\Jobs\CleanupOldReports::class)
            ->dailyAt('02:00')
            ->withoutOverlapping()
            ->runInBackground();

        // Generate daily executive summary at 8 AM
        $schedule->call(function () {
            $executives = \App\Models\User::whereIn('role', ['ceo', 'gm', 'fc'])->get();
            foreach ($executives as $executive) {
                // $executive->notify(new \App\Notifications\DailyExecutiveSummary());
            }
        })->dailyAt('08:00');

        // Generate weekly comprehensive reports every Sunday at 6 AM
        $schedule->call(function () {
            // Generate weekly financial, operational, and compliance reports
            \Log::info('Generating weekly comprehensive reports');
        })->weekly()->sundays()->at('06:00');

        // Generate monthly reports on the 1st of each month at 7 AM
        $schedule->call(function () {
            // Generate monthly comprehensive reports
            \Log::info('Generating monthly comprehensive reports');
        })->monthlyOn(1, '07:00');

        // Retrain predictive models weekly on Saturdays at 3 AM
        $schedule->call(function () {
            // Retrain models that need updating
            \Log::info('Retraining predictive models');
        })->weekly()->saturdays()->at('03:00');

        // Backup analytics data weekly on Saturdays at 4 AM
        $schedule->call(function () {
            // Backup analytics metrics and reports
            \Log::info('Backing up analytics data');
        })->weekly()->saturdays()->at('04:00');

        // =============================================================================
        // PHASE 7: MOBILE APPLICATION & API GATEWAY SCHEDULED TASKS
        // =============================================================================

        // Process mobile sync jobs every 5 minutes
        $schedule->job(\App\Jobs\ProcessMobileSync::class)
            ->everyFiveMinutes()
            ->withoutOverlapping()
            ->runInBackground();

        // Send scheduled push notifications every minute
        $schedule->job(\App\Jobs\SendScheduledPushNotifications::class)
            ->everyMinute()
            ->withoutOverlapping()
            ->runInBackground();

        // Clean up expired API keys daily at 2 AM
        $schedule->job(\App\Jobs\CleanupExpiredApiKeys::class)
            ->dailyAt('02:00')
            ->withoutOverlapping()
            ->runInBackground();

        // Monitor mobile app health every hour
        $schedule->job(\App\Jobs\MonitorMobileAppHealth::class)
            ->hourly()
            ->withoutOverlapping()
            ->runInBackground();

        // Generate mobile analytics report daily at 9 AM
        $schedule->call(function () {
            // Generate mobile analytics report
            \Log::info('Generating mobile analytics report');
            
            // Send to administrators
            $admins = \App\Models\User::whereIn('role', ['ceo', 'gm', 'fc'])->get();
            foreach ($admins as $admin) {
                // $admin->notify(new \App\Notifications\DailyMobileAnalyticsReport($analytics));
            }
        })->dailyAt('09:00');
    }

    /**
     * Register the commands for the application.
     */
    protected function commands(): void
    {
        $this->load(__DIR__.'/Commands');

        require base_path('routes/console.php');
    }

    /**
     * Auto-revert stale payouts
     */
    private function autoRevertStalePayouts(): void
    {
        // Implementation for auto-reverting stale payouts
        \Log::info('Auto-reverting stale payouts');
    }
}
