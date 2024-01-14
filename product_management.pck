create or replace package product_management is
       procedure add_item;
       PROCEDURE add_product(p_product_id NUMBER,p_product_name VARCHAR2,p_price NUMBER,p_stock_quantity NUMBER,p_category_id NUMBER);
       PROCEDURE remove_product(p_product_id NUMBER);
       PROCEDURE list_products_by_price_desc;
       PROCEDURE list_products_by_price_asc;
       PROCEDURE list_products_by_category_price_asc(p_category_id NUMBER);
       PROCEDURE list_products_by_category_price_desc(p_category_id NUMBER);
       PROCEDURE most_sold_products;

end product_management;
/
create or replace package body product_management is
-- Product tablosuna 50 örnek ürün ekleme
       PROCEDURE add_item is


    v_product_name VARCHAR2(100);
    v_category_id NUMBER;
BEGIN
    FOR i IN 1..50 LOOP
        -- Rastgele bir alt kategori seç
        v_category_id := ROUND(DBMS_RANDOM.VALUE(2, 8));

        -- Alt kategoriye göre ürün ismini belirle
        CASE v_category_id
            WHEN 2 THEN v_product_name := 'T-Shirt ' || i;
            WHEN 3 THEN v_product_name := 'Pantolon ' || i;
            WHEN 4 THEN v_product_name := 'Aksesuar ' || i;
            WHEN 6 THEN v_product_name := 'Spor Ayakkaby ' || i;
            WHEN 7 THEN v_product_name := 'Klasik Ayakkaby ' || i;
            WHEN 8 THEN v_product_name := 'Bot ' || i;
            ELSE v_product_name := 'Ürün ' || i;
        END CASE;

        -- Ürünü ekle
        INSERT INTO Product (product_id, product_name, price, stock_quantity, category_id)
        VALUES (i, v_product_name, ROUND(DBMS_RANDOM.VALUE(10, 100), 2), ROUND(DBMS_RANDOM.VALUE(10, 100)), v_category_id);
    END LOOP;
    COMMIT;
END add_item;

-- Fiyata gore artan sirali urunleri listeleyen procedure
PROCEDURE list_products_by_price_asc IS
    CURSOR product_cursor IS
        SELECT *
        FROM Product
        ORDER BY price ASC;
BEGIN
    FOR product_rec IN product_cursor LOOP
        DBMS_OUTPUT.PUT_LINE('Product ID: ' || product_rec.product_id || ', Product Name: ' || product_rec.product_name || ',
         Price: ' || product_rec.price);
    END LOOP;
END list_products_by_price_asc;


-- Fiyata gore azalan sirali urunleri listeleyen procedure
PROCEDURE list_products_by_price_desc IS
    CURSOR product_cursor IS
        SELECT *
        FROM Product
        ORDER BY price DESC;
BEGIN
    FOR product_rec IN product_cursor LOOP
        DBMS_OUTPUT.PUT_LINE('Product ID: ' || product_rec.product_id || ', Product Name: ' || product_rec.product_name || ', Price: ' || product_rec.price);
    END LOOP;
END list_products_by_price_desc;


-- Fiyata göre artan spesifik  urunleri listeleyen procedure
PROCEDURE list_products_by_category_price_asc(p_category_id NUMBER) IS
    CURSOR product_cursor IS
        SELECT *
        FROM Product
        WHERE category_id = p_category_id
        ORDER BY price ASC;
BEGIN
    FOR product_rec IN product_cursor LOOP
        DBMS_OUTPUT.PUT_LINE('Product ID: ' || product_rec.product_id || ', Product Name: ' || product_rec.product_name || ', Price: ' || product_rec.price);
    END LOOP;
END list_products_by_category_price_asc;


-- Fiyata göre azalan spesifik urunleri listeleyen procedure
PROCEDURE list_products_by_category_price_desc(p_category_id NUMBER) IS
    CURSOR product_cursor IS
        SELECT *
        FROM Product
        WHERE category_id = p_category_id
        ORDER BY price DESC;
BEGIN
    FOR product_rec IN product_cursor LOOP
        DBMS_OUTPUT.PUT_LINE('Product ID: ' || product_rec.product_id || ', Product Name: ' || product_rec.product_name ||
         ', Price: ' || product_rec.price);
    END LOOP;
END list_products_by_category_price_desc;


-- Urun ekleyen procedure
PROCEDURE add_product(
    p_product_id NUMBER,
    p_product_name VARCHAR2,
    p_price NUMBER,
    p_stock_quantity NUMBER,
    p_category_id NUMBER
) IS
BEGIN
    INSERT INTO Product (product_id, product_name, price, stock_quantity, category_id)
    VALUES (p_product_id, p_product_name, p_price, p_stock_quantity, p_category_id);

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Urun eklenmistir.');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Urun eklenirken bir hata olustu: ' || SQLERRM);
END add_product;


-- Ürün çýkaran procedure
PROCEDURE remove_product(p_product_id NUMBER) IS
BEGIN
    DELETE FROM Product
    WHERE product_id = p_product_id;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Urun cikarilmistir.');
EXCEPTION
  WHEN no_data_found then
    dbms_output.put_line('Urun bulunamadi.');
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Urun cikarilirken bir hata olustu: ' || SQLERRM);
END remove_product;

PROCEDURE most_sold_products  IS-- En çok satan ürünleri ve satýlma miktarlarýný listeleyen procedure
  BEGIN
    FOR product_row IN (
        SELECT p.product_id, p.product_name, SUM(pi.quantity) AS total_sold
        FROM product p,purchase_item pi
        WHERE p.product_id = pi.product_id 
        GROUP BY p.product_id, p.product_name
        ORDER BY total_sold DESC
    )
    LOOP
        DBMS_OUTPUT.PUT_LINE('Product ID: ' || product_row.product_id ||
                             ', Product Name: ' || product_row.product_name ||
                             ', Total Sold: ' || product_row.total_sold);
    END LOOP;
END most_sold_products;



end product_management;
/
