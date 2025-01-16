document.getElementById('eventForm').addEventListener('submit', async function (e) {
    e.preventDefault();

    const eventData = {
        title: document.getElementById('eventTitle').value,
        description: document.getElementById('eventDescription').value,
        start_date: document.getElementById('eventStartDate').value,
        end_date: document.getElementById('eventEndDate').value,
        location: document.getElementById('eventLocation').value,
        image_url: document.getElementById('eventImageUrl').value,
        category: document.getElementById('eventCategory').value,
    };

    try {
        const response = await fetch('https://your-api-url.com/api/events', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(eventData),
        });

        if (response.ok) {
            alert('Event added successfully!');
            document.getElementById('eventForm').reset();
        } else {
            alert('Failed to add event.');
        }
    } catch (error) {
        console.error('Error:', error);
        alert('An error occurred while adding the event.');
    }
});

document.getElementById('sermonForm').addEventListener('submit', async function (e) {
    e.preventDefault();

    const sermonData = {
        title: document.getElementById('sermonTitle').value,
        preacher: document.getElementById('sermonPreacher').value,
        description: document.getElementById('sermonDescription').value,
        audio_url: document.getElementById('sermonAudioUrl').value,
        image_url: document.getElementById('sermonImageUrl').value,
        sermon_date: document.getElementById('sermonDate').value,
        category: document.getElementById('sermonCategory').value,
    };

    try {
        const response = await fetch('https://your-api-url.com/api/sermons', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(sermonData),
        });

        if (response.ok) {
            alert('Sermon added successfully!');
            document.getElementById('sermonForm').reset();
        } else {
            alert('Failed to add sermon.');
        }
    } catch (error) {
        console.error('Error:', error);
        alert('An error occurred while adding the sermon.');
    }
});