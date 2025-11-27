use Billing;

CREATE TABLE User_table(
    userid INT IDENTITY(1,1) PRIMARY KEY,
    username VARCHAR(30),
    user_password VARCHAR(60),
    email VARCHAR(40),
    phone VARCHAR(15),
    user_address VARCHAR(60),
    user_type VARCHAR(10),

	CONSTRAINT unique_username UNIQUE (username),
	CONSTRAINT unique_email UNIQUE (email),
	CONSTRAINT unique_phone UNIQUE (phone)
);

create table customer(
	customer_id int primary key,
	gender char(1),

	constraint customer_fk foreign key (customer_id)
	references User_table(userid)
);

create table company(
	company_id int primary key,
	com_type varchar(15),
	registration_number varchar(15),

	constraint company_fk foreign key(company_id)
	references User_table(userid)

);
create table bill(
	bill_id INT IDENTITY(1,1) PRIMARY KEY,
	bill_amount int,
	bill_status varchar(10),
	customer_id int,
	company_id int,

	constraint bill_customer_fk foreign key (customer_id)
	references customer(customer_id),

	constraint bill_company_fk foreign key (company_id)
	references company(company_id)
);