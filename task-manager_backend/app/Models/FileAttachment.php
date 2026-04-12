<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class FileAttachment extends Model
{
    use HasFactory;

    protected $fillable = [
        'task_id',
        'filename',
        'original_filename',
        'mime_type',
        'size',
        'path',
    ];

    /**
     * Get the task that owns the file attachment.
     */
    public function task(): BelongsTo
    {
        return $this->belongsTo(Task::class);
    }
}
