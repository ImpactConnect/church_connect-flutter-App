-- Create the ebooks table
CREATE TABLE IF NOT EXISTS ebooks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL,
    author TEXT NOT NULL,
    description TEXT NOT NULL,
    thumbnail_url TEXT NOT NULL,
    book_url TEXT NOT NULL,
    category TEXT NOT NULL,
    published_date TIMESTAMP WITH TIME ZONE NOT NULL,
    is_book_of_week BOOLEAN DEFAULT false,
    is_recommended BOOLEAN DEFAULT false,
    view_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create function to update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger for updating the updated_at column
CREATE TRIGGER update_ebooks_updated_at
    BEFORE UPDATE
    ON ebooks
    FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- Create function to increment view count
CREATE OR REPLACE FUNCTION increment_book_view_count(book_id UUID)
RETURNS VOID AS $$
BEGIN
    UPDATE ebooks
    SET view_count = view_count + 1
    WHERE id = book_id;
END;
$$ LANGUAGE plpgsql;

-- Insert dummy data
INSERT INTO ebooks (
    title,
    author,
    description,
    thumbnail_url,
    book_url,
    category,
    published_date,
    is_book_of_week,
    is_recommended
) VALUES
(
    'The Purpose Driven Life',
    'Rick Warren',
    'A groundbreaking manifesto on the meaning of life. The book suggests that we are created for a specific purpose by God.',
    'https://m.media-amazon.com/images/I/71DLF3hL3XL._AC_UF1000,1000_QL80_.jpg',
    'https://example.com/purpose-driven-life.pdf',
    'Christian Living',
    '2002-10-23',
    true,
    true
),
(
    'Mere Christianity',
    'C.S. Lewis',
    'A theological book that examines the fundamentals of Christian belief, adapted from a series of BBC radio talks.',
    'https://m.media-amazon.com/images/I/71u6BhYIRxL._AC_UF1000,1000_QL80_.jpg',
    'https://example.com/mere-christianity.pdf',
    'Theology',
    '1952-01-01',
    false,
    true
),
(
    'The Battle Plan for Prayer',
    'Stephen Kendrick, Alex Kendrick',
    'A comprehensive guide to developing a stronger prayer life and creating a prayer strategy.',
    'https://m.media-amazon.com/images/I/81YgPxr+BVL._AC_UF1000,1000_QL80_.jpg',
    'https://example.com/battle-plan-prayer.pdf',
    'Prayer',
    '2015-08-01',
    false,
    true
),
(
    'Boundaries',
    'Henry Cloud, John Townsend',
    'A guide to setting healthy boundaries with family, friends, and colleagues from a Christian perspective.',
    'https://m.media-amazon.com/images/I/71QKQ9mwV7L._AC_UF1000,1000_QL80_.jpg',
    'https://example.com/boundaries.pdf',
    'Christian Living',
    '1992-09-01',
    false,
    true
),
(
    'Jesus Calling',
    'Sarah Young',
    'A devotional filled with uniquely inspired treasures from heaven for every day of the year.',
    'https://m.media-amazon.com/images/I/61lDxASwR5L._SY466_.jpg',
    'https://example.com/jesus-calling.pdf',
    'Devotional',
    '2004-10-10',
    true,
    true
);
