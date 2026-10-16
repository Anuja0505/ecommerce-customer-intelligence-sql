-- Add a composite primary key to order_reviews
ALTER TABLE order_reviews
ADD CONSTRAINT order_reviews_pkey
PRIMARY KEY (review_id, order_id);