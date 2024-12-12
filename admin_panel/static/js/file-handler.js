class FileHandler {
    static async uploadFile(file, onProgress) {
        return new Promise((resolve, reject) => {
            const formData = new FormData();
            formData.append('file', file);

            const xhr = new XMLHttpRequest();

            xhr.upload.addEventListener('progress', (event) => {
                if (event.lengthComputable) {
                    const progress = (event.loaded / event.total) * 100;
                    if (onProgress) onProgress(progress);
                }
            });

            xhr.onload = () => {
                if (xhr.status === 200) {
                    resolve(JSON.parse(xhr.responseText));
                } else {
                    reject(new Error('Upload failed'));
                }
            };

            xhr.onerror = () => reject(new Error('Upload failed'));

            xhr.open('POST', '/api/upload');
            xhr.setRequestHeader('Authorization', `Bearer ${localStorage.getItem('token')}`);
            xhr.send(formData);
        });
    }

    static getFileSize(size) {
        const units = ['B', 'KB', 'MB', 'GB'];
        let unitIndex = 0;
        
        while (size >= 1024 && unitIndex < units.length - 1) {
            size /= 1024;
            unitIndex++;
        }

        return `${size.toFixed(1)} ${units[unitIndex]}`;
    }

    static validateAudioFile(file) {
        const allowedTypes = ['audio/mp3', 'audio/mpeg', 'audio/wav', 'audio/x-m4a'];
        const maxSize = 100 * 1024 * 1024; // 100MB

        if (!allowedTypes.includes(file.type)) {
            throw new Error('Invalid file type. Please upload MP3, WAV, or M4A files.');
        }

        if (file.size > maxSize) {
            throw new Error('File size exceeds 100MB limit.');
        }

        return true;
    }
} 