CREATE TABLE customers (
	customer_id SERIAL PRIMARY KEY,
	name TEXT NOT NULL,
	gender VARCHAR(1) CHECK (gender IN ('M', 'F')),
	dob DATE,
	signup_date DATE NOT NULL,
	city TEXT
);

CREATE TABLE accounts (
    account_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customers(customer_id),
    account_type VARCHAR(20) CHECK (account_type IN ('savings', 'current', 'loan')),
    open_date DATE NOT NULL,
    balance NUMERIC(12,2) DEFAULT 0
);
ALTER TABLE accounts ADD COLUMN account_number TEXT;

CREATE TABLE transactions (
    transaction_id SERIAL PRIMARY KEY,
    account_id INT REFERENCES accounts(account_id),
    transaction_date DATE NOT NULL,
    amount NUMERIC(12,2) NOT NULL,
    transaction_type VARCHAR(20),     
    description VARCHAR(50) 
);
