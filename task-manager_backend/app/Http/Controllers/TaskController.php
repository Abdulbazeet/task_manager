<?php

namespace App\Http\Controllers;

use App\Http\Requests\TaskRequest;
use App\Models\Task;
use App\Models\FileAttachment;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class TaskController extends Controller
{
    /**
     * Get all tasks with filtering and pagination.
     */
    public function index(Request $request): JsonResponse
    {
        try {
            $query = auth()->user()->tasks();

            // Filter by status
            if ($request->has('status') && $request->status) {
                $query->where('status', $request->status);
            }

            // Filter by priority
            if ($request->has('priority') && $request->priority) {
                $query->where('priority', $request->priority);
            }

            // Sorting
            $sortBy = $request->get('sort_by', 'created_at');
            $sortOrder = $request->get('sort_order', 'desc');
            $query->orderBy($sortBy, $sortOrder);

            // Pagination
            $perPage = $request->get('per_page', 15);
            $tasks = $query->paginate($perPage);

            return response()->json([
                'message' => 'Tasks retrieved successfully',
                'data' => $tasks->items(),
                'pagination' => [
                    'total' => $tasks->total(),
                    'per_page' => $tasks->perPage(),
                    'current_page' => $tasks->currentPage(),
                    'last_page' => $tasks->lastPage(),
                ],
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Failed to retrieve tasks',
                'errors' => ['general' => $e->getMessage()],
            ], 500);
        }
    }

    /**
     * Create a new task.
     */
    public function store(TaskRequest $request): JsonResponse
    {
        try {
            $task = auth()->user()->tasks()->create([
                'title' => $request->validated()['title'],
                'description' => $request->validated()['description'] ?? null,
                'status' => $request->validated()['status'],
                'priority' => $request->validated()['priority'],
                'due_date' => $request->validated()['due_date'] ?? null,
            ]);

            return response()->json([
                'message' => 'Task created successfully',
                'data' => $task,
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Failed to create task',
                'errors' => ['general' => $e->getMessage()],
            ], 500);
        }
    }

    /**
     * Get a specific task.
     */
    public function show($id): JsonResponse
    {
        try {
            $task = auth()->user()->tasks()->findOrFail($id);

            return response()->json([
                'message' => 'Task retrieved successfully',
                'data' => $task->load('attachments'),
            ], 200);
        } catch (\Illuminate\Database\Eloquent\ModelNotFoundException $e) {
            return response()->json([
                'message' => 'Task not found',
                'errors' => ['task' => 'The requested task does not exist'],
            ], 404);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Failed to retrieve task',
                'errors' => ['general' => $e->getMessage()],
            ], 500);
        }
    }

    /**
     * Update a task.
     */
    public function update(TaskRequest $request, $id): JsonResponse
    {
        try {
            $task = auth()->user()->tasks()->findOrFail($id);

            $task->update([
                'title' => $request->validated()['title'],
                'description' => $request->validated()['description'] ?? $task->description,
                'status' => $request->validated()['status'],
                'priority' => $request->validated()['priority'],
                'due_date' => $request->validated()['due_date'] ?? $task->due_date,
            ]);

            return response()->json([
                'message' => 'Task updated successfully',
                'data' => $task,
            ], 200);
        } catch (\Illuminate\Database\Eloquent\ModelNotFoundException $e) {
            return response()->json([
                'message' => 'Task not found',
                'errors' => ['task' => 'The requested task does not exist'],
            ], 404);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Failed to update task',
                'errors' => ['general' => $e->getMessage()],
            ], 500);
        }
    }

    /**
     * Delete a task.
     */
    public function destroy($id): JsonResponse
    {
        try {
            $task = auth()->user()->tasks()->findOrFail($id);

            // Delete associated files
            foreach ($task->attachments as $attachment) {
                Storage::disk('public')->delete($attachment->path);
                $attachment->delete();
            }

            $task->delete();

            return response()->json([
                'message' => 'Task deleted successfully',
            ], 200);
        } catch (\Illuminate\Database\Eloquent\ModelNotFoundException $e) {
            return response()->json([
                'message' => 'Task not found',
                'errors' => ['task' => 'The requested task does not exist'],
            ], 404);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Failed to delete task',
                'errors' => ['general' => $e->getMessage()],
            ], 500);
        }
    }

    /**
     * Attach a file to a task.
     */
    public function attachFile(Request $request, $id): JsonResponse
    {
        try {
            $task = auth()->user()->tasks()->findOrFail($id);

            // Validate file
            $request->validate([
                'file' => 'required|file|max:2048|mimes:pdf,jpg,jpeg,png,gif',
            ], [
                'file.required' => 'File is required',
                'file.max' => 'File size must not exceed 2 MB',
                'file.mimes' => 'File must be an image (jpg, jpeg, png, gif) or PDF',
            ]);

            if ($request->hasFile('file')) {
                $file = $request->file('file');
                $originalName = $file->getClientOriginalName();
                $extension = $file->getClientOriginalExtension();
                $filename = uniqid('task_' . $task->id . '_') . '.' . $extension;

                // Store the file
                $path = Storage::disk('public')->putFileAs('tasks', $file, $filename);

                // Create file attachment record
                $attachment = FileAttachment::create([
                    'task_id' => $task->id,
                    'filename' => $filename,
                    'original_filename' => $originalName,
                    'mime_type' => $file->getMimeType(),
                    'size' => $file->getSize(),
                    'path' => $path,
                ]);

                return response()->json([
                    'message' => 'File attached successfully',
                    'data' => $attachment,
                ], 201);
            }

            return response()->json([
                'message' => 'No file provided',
                'errors' => ['file' => 'File is required'],
            ], 400);
        } catch (\Illuminate\Database\Eloquent\ModelNotFoundException $e) {
            return response()->json([
                'message' => 'Task not found',
                'errors' => ['task' => 'The requested task does not exist'],
            ], 404);
        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json([
                'message' => 'Validation failed',
                'errors' => $e->errors(),
            ], 422);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Failed to attach file',
                'errors' => ['general' => $e->getMessage()],
            ], 500);
        }
    }
}
