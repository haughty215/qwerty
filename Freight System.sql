-- Drop existing objects (if they exist)
DROP TABLE InternationalShipment CASCADE CONSTRAINTS;
DROP TABLE DomesticShipment CASCADE CONSTRAINTS;
DROP TABLE Shipment CASCADE CONSTRAINTS;
DROP TABLE Packagess CASCADE CONSTRAINTS;
DROP TABLE Shipper CASCADE CONSTRAINTS;
DROP TABLE Recipient CASCADE CONSTRAINTS;
DROP TYPE Address FORCE;
DROP TYPE Contact FORCE;
DROP TYPE Dimensionss FORCE;

-- Create Dimensions type
CREATE TYPE Dimensionss AS OBJECT (
    length NUMBER(8,2),
    width NUMBER(8,2),
    height NUMBER(8,2)
);

-- Create Contact type
CREATE TYPE Contact AS OBJECT (
    name VARCHAR2(100),
    email VARCHAR2(100),
    phone VARCHAR2(20)
);

-- Create Address type
CREATE TYPE Address AS OBJECT (
    street VARCHAR2(100),
    city VARCHAR2(50),
    state VARCHAR2(50),
    zipCode VARCHAR2(10),
    country VARCHAR2(50)
);

-- Create Shipper table
CREATE TABLE Shipper (
    shipperID NUMBER PRIMARY KEY,
    name VARCHAR2(100) NOT NULL,
    contact Contact
);

-- Create Recipient table
CREATE TABLE Recipient (
    recipientID NUMBER PRIMARY KEY,
    name VARCHAR2(100) NOT NULL,
    contact Contact
);


-- Create Shipment table (Base class)
CREATE TABLE Shipment (
    shipmentID NUMBER PRIMARY KEY,
    shipperID NUMBER NOT NULL,
    recipientID NUMBER NOT NULL,
    origin Address,
    destination Address,
    status VARCHAR2(50) NOT NULL,
    shippingDate DATE,
    deliveryDate DATE,
    FOREIGN KEY (shipperID) REFERENCES Shipper(shipperID),
    FOREIGN KEY (recipientID) REFERENCES Recipient(recipientID)
);

-- Create Package table
CREATE TABLE Packagess (
    packageID NUMBER PRIMARY KEY,
    shipmentID NUMBER,
    weight NUMBER(8,2) NOT NULL,
    dimensionss Dimensionss,
    contentss VARCHAR2(200),
    FOREIGN KEY (shipmentID) REFERENCES Shipment(shipmentID)
);

-- Create InternationalShipment table (Subclass)
CREATE TABLE InternationalShipment (
    shipmentID NUMBER PRIMARY KEY,
    customsDeclaration VARCHAR2(200),
    importDuties NUMBER(10,2),
    FOREIGN KEY (shipmentID) REFERENCES Shipment(shipmentID)
);

-- Create DomesticShipment table (Subclass)
CREATE TABLE DomesticShipment (
    shipmentID NUMBER PRIMARY KEY,
    deliveryInstructions VARCHAR2(200),
    FOREIGN KEY (shipmentID) REFERENCES Shipment(shipmentID)
);


-- Function: Calculate Package Volume
CREATE OR REPLACE FUNCTION calculate_packages_volume (
    p_dimensionss Dimensionss
) RETURN NUMBER IS
    volume NUMBER;
BEGIN
    volume := p_dimensionss.length * p_dimensionss.width * p_dimensionss.height;
    RETURN volume;
END;
/
-- Trigger: Update Shipment Status on Delivery

CREATE OR REPLACE TRIGGER update_shipment_status
BEFORE UPDATE ON Shipment
FOR EACH ROW
BEGIN
    IF :NEW.deliveryDate IS NOT NULL AND :OLD.deliveryDate IS NULL THEN
        :NEW.status := 'Delivered';
    END IF;
END;
/

---Stored Procedure: update_shipment_delivery_date
CREATE OR REPLACE PROCEDURE update_shipment_delivery_date (
    p_shipmentID IN NUMBER,
    p_deliveryDate IN DATE
) IS
BEGIN
    -- Update the delivery date of the shipment
    UPDATE Shipment
    SET deliveryDate = p_deliveryDate
    WHERE shipmentID = p_shipmentID;

    -- Check if the update was successful
    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Shipment not found or already delivered.');
    END IF;

    COMMIT; -- Commit the changes

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK; -- Rollback changes in case of error
        DBMS_OUTPUT.PUT_LINE('Error updating delivery date: ' || SQLERRM);
END;
/





-- Insert into shipper 
INSERT INTO Shipper (shipperID, name, contact) VALUES (1, 'SwiftTransit', Contact('Sthebu Israel', 'isthebu@swifttransit.com', '7485-8577'));
INSERT INTO Shipper (shipperID, name, contact) VALUES (2, 'RapidLogistics', Contact('Ami Otsetswe', 'amiotse@rapidlogistics.com', '748-987-140-957'));
INSERT INTO Shipper (shipperID, name, contact) VALUES (3, 'SpeedyCourier', Contact('Betty Kefa', 'kefab@speedycourier.com', '890-123-4567'));
INSERT INTO Shipper (shipperID, name, contact) VALUES (4, 'FlashFreight', Contact('Sekabi Alibaba', 'salibaba@flashfreight.com', '901-234-5678'));
INSERT INTO Shipper (shipperID, name, contact) VALUES (5, 'QuickShip', Contact('Alex Bray', 'alex.bray@quickship.com', '8998-9857-9857'));

--  insert into recipient 
INSERT INTO Recipient (recipientID, name, contact) VALUES (1, 'Amantle Babs', Contact('Amantle Babs', 'lou.mary@gmail.com', '74569874'));
INSERT INTO Recipient (recipientID, name, contact) VALUES (2, 'Boineelo Bible', Contact('Boineelo Bible', 'bbible@icloud.com', '74568978'));
INSERT INTO Recipient (recipientID, name, contact) VALUES (3, 'Billy Ronald', Contact('Billy Ronald', 'daniel.clark@yahoo.com', '432-109-8765'));
INSERT INTO Recipient (recipientID, name, contact) VALUES (4, 'Sophie Rori', Contact('Sophie Rori', 'sophie.rori@gmail.com', '78923145'));
INSERT INTO Recipient (recipientID, name, contact) VALUES (5, 'Noah Martinez', Contact('Noah Martinez', 'noah.martinez@yahoo.com', '654-321-0987'));

-- insert into shipments
INSERT INTO Shipment (shipmentID, shipperID, recipientID, origin, destination, status, shippingDate, deliveryDate) VALUES (1, 1, 5, Address('135 Gopong Street', 'Betesankwe', 'GB', '02101', 'Botswana'), Address('246 Receiving St', 'Gaborone', 'CA', '92101', 'Botswana'), 'In Transit', TO_DATE('2024-05-28', 'YYYY-MM-DD'), NULL);
INSERT INTO Shipment (shipmentID, shipperID, recipientID, origin, destination, status, shippingDate, deliveryDate) VALUES(2, 2, 4, Address('579 Works Street', 'Sunderland', 'WS', '19101', 'UK'), Address('753 Delivery Rd', 'Dallas', 'London', '75201', 'UK'), 'Delivered', TO_DATE('2024-05-20', 'YYYY-MM-DD'), TO_DATE('2024-05-25', 'YYYY-MM-DD'));
INSERT INTO Shipment (shipmentID, shipperID, recipientID, origin, destination, status, shippingDate, deliveryDate) VALUES(3, 3, 3, Address('963 Express St', 'Bellingham', 'EB', '97201', 'South Africa'), Address('147 Dropoff St', 'Cape Town', 'NV', '89101', 'South Africa'), 'Pending', TO_DATE('2024-05-29', 'YYYY-MM-DD'), NULL);
INSERT INTO Shipment (shipmentID, shipperID, recipientID, origin, destination, status, shippingDate, deliveryDate) VALUES(4, 4, 2, Address('258 Below St', 'Haaland', 'BH', '48201', 'UK'), Address('369 Pickup Blvd', 'Tableham', 'MN', '55401', 'UK'), 'In Transit', TO_DATE('2024-05-27', 'YYYY-MM-DD'), NULL);
INSERT INTO Shipment (shipmentID, shipperID, recipientID, origin, destination, status, shippingDate, deliveryDate) VALUES(5, 5, 1, Address('741 Nopes Ave', 'Sterling', 'NS', '32801', 'USA'), Address('852 Freight St', 'Martin', 'LA', '70112', 'USA'), 'In Transit', TO_DATE('2024-05-26', 'YYYY-MM-DD'), NULL);

INSERT INTO Shipment (shipmentID, shipperID, recipientID, origin, destination, status, shippingDate, deliveryDate) VALUES (6, 1, 1, Address('178 Gopong Street', 'Betesankwe', 'GS', '78985', 'Botswana'), Address('278 Fairgrounds', 'Gaborone', 'CA', '92101', 'Botswana'), 'In Transit', TO_DATE('2024-05-28', 'YYYY-MM-DD'), NULL);
INSERT INTO Shipment (shipmentID, shipperID, recipientID, origin, destination, status, shippingDate, deliveryDate) VALUES(7, 2, 2, Address('897 Phakalane', 'Spoons', 'PKS', '78985', 'Botswana'), Address('898 CBD', 'Block 10', 'Gaborone', '75201', 'Botswana'), 'Delivered', TO_DATE('2024-05-20', 'YYYY-MM-DD'), TO_DATE('2024-05-25', 'YYYY-MM-DD'));
INSERT INTO Shipment (shipmentID, shipperID, recipientID, origin, destination, status, shippingDate, deliveryDate) VALUES(8, 3, 3, Address('745 Block 10', 'Sarona', 'BT', '78985', 'Botswana'), Address('997 Main Mall', 'Area 1', 'Francistown', '89101', 'Botswana'), 'Pending', TO_DATE('2024-05-29', 'YYYY-MM-DD'), NULL);


-- insert into packages 
INSERT INTO Packagess (packageID, shipmentID, weight, dimensionss, contentss) VALUES (1, 1, 20.0, Dimensionss(40.0, 30.0, 20.0), 'Electronics and gadgets');
INSERT INTO Packagess (packageID, shipmentID, weight, dimensionss, contentss) VALUES (2, 2, 7.5, Dimensionss(15.0, 10.0, 8.0), 'Home decor items');
INSERT INTO Packagess (packageID, shipmentID, weight, dimensionss, contentss) VALUES (3, 3, 4.0, Dimensionss(12.0, 8.0, 6.0), 'Art supplies');
INSERT INTO Packagess (packageID, shipmentID, weight, dimensionss, contentss) VALUES(4, 4, 6.0, Dimensionss(18.0, 12.0, 10.0), 'Sports equipment');
INSERT INTO Packagess (packageID, shipmentID, weight, dimensionss, contentss) VALUES(5, 5, 9.5, Dimensionss(20.0, 15.0, 12.0), 'Office supplies');

--- insert into  internationalshipment 
INSERT INTO InternationalShipment (shipmentID, customsDeclaration, importDuties) VALUES (1, 'Electronics and gadgets for personal use', 75.00);
INSERT INTO InternationalShipment (shipmentID, customsDeclaration, importDuties) VALUES (2, 'Home decor items for personal use', 15.00);
INSERT INTO InternationalShipment (shipmentID, customsDeclaration, importDuties) VALUES (3, 'Art supplies for personal use', 5.00);
INSERT INTO InternationalShipment (shipmentID, customsDeclaration, importDuties) VALUES (4, 'Sports equipment for personal use', 10.00);
INSERT INTO InternationalShipment (shipmentID, customsDeclaration, importDuties) VALUES (5, 'Office supplies for personal use', 20.00);


--- insert into domestics shipment
INSERT INTO DomesticShipment (shipmentID, deliveryInstructions) VALUES  (6, 'Leave at the front desk');
INSERT INTO DomesticShipment (shipmentID, deliveryInstructions) VALUES (7, 'Deliver to the recipient in person');
INSERT INTO DomesticShipment (shipmentID, deliveryInstructions) VALUES (8, 'Leave at the doorstep');

Select * from Shipper;
Select * from Recipient;
select * from shipment;
Select * from Packegess;
Select * from InternationalShipment;
select * from DomesticShipment;

-- a. A join of three or more tables using multiple types of join operations
--This query joins the Shipment, Shipper, Recipient, and Packagess tables using inner and left joins and includes a restriction on the rows selected (shipments in transit).
SELECT s.shipmentID, sh.name AS shipper_name, r.name AS recipient_name, p.packageID, p.contentss
FROM Shipment s
INNER JOIN Shipper sh ON s.shipperID = sh.shipperID
INNER JOIN Recipient r ON s.recipientID = r.recipientID
LEFT JOIN Packagess p ON s.shipmentID = p.shipmentID
WHERE s.status = 'In Transit';

--- b A query which uses one (or more) of the UNION, MINUS or INTERSECT operators.
-- SElects the minus 
SELECT shipmentID FROM DomesticShipment
    MINUS
SELECT shipmentID FROM InternationalShipment



---c A query which requires use of either a nested table, sub-types
--Retrieve the package ID and its volume by calculating the volume using the Dimensionss sub-type.
-- Create the nested table type
SELECT 
    s.shipmentID,
    s.status,
    s.shippingDate,
    s.deliveryDate,
    sh.name AS shipper_name,
    r.name AS recipient_name,
    p.packageID,
    p.weight,
    p.contentss,
    p.dimensionss.length AS package_length,
    p.dimensionss.width AS package_width,
    p.dimensionss.height AS package_height
FROM 
    Shipment s
JOIN 
    Shipper sh ON s.shipperID = sh.shipperID
JOIN 
    Recipient r ON s.recipientID = r.recipientID
JOIN 
    Packagess p ON s.shipmentID = p.shipmentID;


----d.  A query using temporal features of Oracle SQL
--- This query calculates the duration between the shipping date and the delivery date for all shipments.
CREATE OR REPLACE FUNCTION GetShipmentDurations
RETURN SYS_REFCURSOR IS
    shipment_cursor SYS_REFCURSOR;
BEGIN
    OPEN shipment_cursor FOR
        SELECT shipmentID, 
               shippingDate, 
               deliveryDate, 
               (deliveryDate - shippingDate) AS duration_days
        FROM Shipment
        WHERE deliveryDate IS NOT NULL;
    RETURN shipment_cursor;
END GetShipmentDurations;
/
    
DECLARE
    v_cursor SYS_REFCURSOR;
    v_shipmentID Shipment.shipmentID%TYPE;
    v_shippingDate Shipment.shippingDate%TYPE;
    v_deliveryDate Shipment.deliveryDate%TYPE;
    v_duration_days NUMBER;
BEGIN
    v_cursor := GetShipmentDurations;
    LOOP
        FETCH v_cursor INTO v_shipmentID, v_shippingDate, v_deliveryDate, v_duration_days;
        EXIT WHEN v_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Shipment ID: ' || v_shipmentID || 
                             ', Shipping Date: ' || v_shippingDate || 
                             ', Delivery Date: ' || v_deliveryDate || 
                             ', Duration (days): ' || v_duration_days);
    END LOOP;
    CLOSE v_cursor;
END;
/
---e. A query using OLAP features
--The procedure `calculate_total_package_weight_olap` calculates and displays the total weight of packages for each shipment and each shipper, including subtotals and the overall total using the ROLLUP operator for hierarchical grouping.

SELECT sh.shipperID, s.shipmentID, SUM(p.weight) AS total_weight
FROM Shipper sh
JOIN Shipment s ON sh.shipperID = s.shipperID
JOIN Packagess p ON s.shipmentID = p.shipmentID
GROUP BY ROLLUP (sh.shipperID, s.shipmentID);

