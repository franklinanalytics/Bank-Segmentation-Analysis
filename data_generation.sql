-- Insert 200 realistic Nigerian customers
INSERT INTO customers (name, gender, dob, signup_date, city)
SELECT 
    -- Full Name: Firstname + Lastname
    first_names[ceil(random() * array_length(first_names, 1))] || ' ' ||
    last_names[ceil(random() * array_length(last_names, 1))],

    -- Random gender
    CASE WHEN random() < 0.5 THEN 'M' ELSE 'F' END,

    -- Random date of birth (between 1970 and 1997)
    DATE '1970-01-01' + (trunc(random() * 10000)::int) * INTERVAL '1 day',

    -- Random signup date within last 3 years
    CURRENT_DATE - (trunc(random() * 1095)::int) * INTERVAL '1 day',

    -- Random city
    cities[ceil(random() * array_length(cities, 1))]
FROM generate_series(1, 200),
LATERAL (
    SELECT 
        ARRAY[
            'Chinedu', 'Aisha', 'Tunde', 'Ngozi', 'Bola', 'Obinna', 'Fatima', 'Yakubu',
            'Emeka', 'Zainab', 'Ifeanyi', 'Uche', 'Abubakar', 'Lilian', 'Segun', 'Halima', 
			'Adesuwa', 'Kehinde', 'Mercy', 'Emmanuel'
        ] AS first_names,
        ARRAY[
            'Okonkwo', 'Balogun', 'Adegoke', 'Nwachukwu', 'Danjuma', 'Adelaja', 'Ibrahim',
            'Umeh', 'Ogunleye', 'Abiola', 'Mohammed', 'Eze', 'Lawal', 'Obi', 'Ahmed', 'Onyeka',
			'Nwabueze', 'Ajibade', 'Suleman', 'Johnson'
        ] AS last_names,
        ARRAY[
            'Lagos', 'Abuja', 'Port Harcourt', 'Enugu', 'Kano', 'Ibadan', 'Jos', 'Abeokuta',
            'Calabar', 'Owerri', 'Benin City', 'Kaduna'
        ] AS cities
) name_data;

SELECT * FROM customers

-- Insert accounts (1-2 per customer) with realistic 10-digit account numbers and random balances
INSERT INTO accounts (customer_id, account_number, account_type, open_date, balance)
SELECT 
    c.customer_id,
    LPAD((trunc(random() * 1e10)::bigint)::text, 10, '0') AS account_number,
    (ARRAY['savings', 'current', 'loan'])[floor(random() * 3 + 1)],
    c.signup_date + (trunc(random() * 90)::int) * INTERVAL '1 day',
    round((1000 + random() * 499000)::numeric, 2)
FROM customers c
JOIN generate_series(1, 2) AS dup(n) ON true
WHERE random() < 0.75		-- Around 75% of customers get a second account
ORDER BY c.customer_id
LIMIT 1000;

SELECT * FROM accounts

-- Insert 1000 well-randomized transactions
INSERT INTO transactions (account_id, transaction_type, amount, transaction_date, description)
SELECT 
    t.account_id,
    t.transaction_type,
    t.amount,
    t.transaction_date,
    d.description
FROM (
    SELECT 
        a.account_id,
        -- Randomly assign credit or debit
        CASE 
            WHEN random() < 0.5 THEN 'debit' 
            ELSE 'credit' 
        END AS transaction_type,
        -- Random amount between 500 and 250,000
        ROUND((500 + random() * 249500)::numeric, 2) AS amount,
        -- Random date within past 2 years
        NOW() - (trunc(random() * 730) || ' days')::INTERVAL AS transaction_date
    FROM accounts a,
         generate_series(1, 10) gs
) t
-- Attach description based on type
JOIN LATERAL (
    SELECT 
        CASE 
            WHEN t.transaction_type = 'credit' THEN
                (ARRAY[
                    'Salary credited',
                    'Bank transfer from GTBank',
                    'Credit alert from Zenith',
                    'Reversal of failed transaction',
                    'Loan disbursement',
                    'Wallet top-up',
                    'Refund from vendor',
                    'POS reversal',
                    'Received from customer',
                    'Online payment received',
                    'Cash deposit'
                ])[FLOOR(random() * 11 + 1)::int]
            ELSE
                (ARRAY[
                    'POS payment at Shoprite',
                    'MTN Airtime recharge',
                    'Fuel purchase at Mobil',
                    'Electricity bill payment',
                    'Loan EMI debit',
                    'House rent payment',
                    'Online purchase at Jumia',
                    'Cash withdrawal from ATM',
                    'Subscription payment',
                    'Insurance premium debit',
                    'Bank transfer to Fidelity Bank'
                ])[FLOOR(random() * 11 + 1)::int]
        END AS description
) d ON TRUE
ORDER BY random()
LIMIT 1000;

SELECT * FROM transactions

-- Confirm balanced transaction type
SELECT 
	transaction_type, 
	COUNT(*) 
FROM transactions 
GROUP BY transaction_type;

-- See variety of descriptions
SELECT 
	description, 
	COUNT(*) 
FROM transactions 
GROUP BY description 
ORDER BY COUNT(*) DESC;

-- Count total rows
SELECT 
	COUNT(*) 
FROM transactions;

