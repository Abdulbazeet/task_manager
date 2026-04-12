<?php

namespace App\Http\Requests;

use Illuminate\Contracts\Validation\ValidationRule;
use Illuminate\Foundation\Http\FormRequest;

class TaskRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'title' => 'required|string|max:255',
            'description' => 'nullable|string|max:1000',
            'status' => 'required|in:pending,in-progress,done',
            'priority' => 'required|in:low,medium,high',
            'due_date' => 'nullable|date|date_format:Y-m-d',
        ];
    }

    /**
     * Get custom messages for validator errors.
     */
    public function messages(): array
    {
        return [
            'title.required' => 'Task title is required',
            'title.max' => 'Task title must not exceed 255 characters',
            'status.required' => 'Status is required',
            'status.in' => 'Status must be pending, in-progress, or done',
            'priority.required' => 'Priority is required',
            'priority.in' => 'Priority must be low, medium, or high',
            'due_date.date' => 'Due date must be a valid date',
            'due_date.date_format' => 'Due date must be in YYYY-MM-DD format',
        ];
    }
}
