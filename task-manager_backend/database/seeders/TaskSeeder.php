<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\Task;

class TaskSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Get or create a test user
        $user = User::first() ?? User::create([
            'name' => 'John Doe',
            'email' => 'john@example.com',
            'password' => 'password123',
        ]);

        // Sample tasks data
        $tasks = [
            [
                'title' => 'Complete Project Proposal',
                'description' => 'Write and submit the Q2 project proposal to the team lead',
                'status' => 'in-progress',
                'priority' => 'high',
                'due_date' => now()->addDays(3),
            ],
            [
                'title' => 'Review Code Changes',
                'description' => 'Review pull request #45 from the dev team',
                'status' => 'pending',
                'priority' => 'high',
                'due_date' => now()->addDays(1),
            ],
            [
                'title' => 'Update Documentation',
                'description' => 'Update API documentation for v2.0 release',
                'status' => 'pending',
                'priority' => 'medium',
                'due_date' => now()->addDays(7),
            ],
            [
                'title' => 'Fix Login Bug',
                'description' => 'Fix the authentication issue on the mobile app login screen',
                'status' => 'in-progress',
                'priority' => 'high',
                'due_date' => now()->addDays(2),
            ],
            [
                'title' => 'Setup Database Backups',
                'description' => 'Configure automatic daily backups for production database',
                'status' => 'done',
                'priority' => 'high',
                'due_date' => now()->subDays(5),
            ],
            [
                'title' => 'Prepare Presentation',
                'description' => 'Create slides for the team meeting presentation',
                'status' => 'pending',
                'priority' => 'medium',
                'due_date' => now()->addDays(5),
            ],
            [
                'title' => 'Optimize Database Queries',
                'description' => 'Profile and optimize slow database queries in the reporting module',
                'status' => 'in-progress',
                'priority' => 'medium',
                'due_date' => now()->addDays(10),
            ],
            [
                'title' => 'Test Payment Integration',
                'description' => 'Test all payment gateway integrations in staging environment',
                'status' => 'pending',
                'priority' => 'high',
                'due_date' => now()->addDays(4),
            ],
            [
                'title' => 'Deploy to Production',
                'description' => 'Deploy v1.5 release to production environment',
                'status' => 'pending',
                'priority' => 'high',
                'due_date' => now()->addDays(14),
            ],
            [
                'title' => 'Team Training Session',
                'description' => 'Conduct training session for new team members on the codebase',
                'status' => 'done',
                'priority' => 'low',
                'due_date' => now()->subDays(10),
            ],
            [
                'title' => 'Client Meeting',
                'description' => 'Meet with client to discuss project requirements',
                'status' => 'pending',
                'priority' => 'high',
                'due_date' => now()->addDays(2),
            ],
            [
                'title' => 'Refactor User Module',
                'description' => 'Refactor user authentication module to use JWT',
                'status' => 'in-progress',
                'priority' => 'medium',
                'due_date' => now()->addDays(8),
            ],
        ];

        // Create tasks for the user
        foreach ($tasks as $taskData) {
            Task::create(array_merge($taskData, [
                'user_id' => $user->id,
            ]));
        }
    }
}
