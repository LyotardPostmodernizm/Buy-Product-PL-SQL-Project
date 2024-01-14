create or replace package buying_management is
       PROCEDURE add_to_basket(p_basket_id NUMBER,p_user_id NUMBER,p_product_id NUMBER,p_quantity NUMBER);
       PROCEDURE remove_from_basket(p_user_id NUMBER,p_product_id NUMBER,p_quantity NUMBER);
       procedure view_basket(p_user_id number);
       PROCEDURE add_to_basket_or_create(p_user_id NUMBER,p_product_id NUMBER,p_quantity NUMBER);
       PROCEDURE buy(p_user_id NUMBER);
       PROCEDURE view_purchase_history(p_user_id NUMBER);
       PROCEDURE export_purchase_history_to_csv(p_user_id NUMBER);
       PROCEDURE add_favourite(p_user_id NUMBER, p_product_id NUMBER);
       PROCEDURE remove_favorite(p_user_id NUMBER, p_product_id NUMBER);
       PROCEDURE list_favourite_products(p_user_id NUMBER);
end buying_management;
/
create or replace package body buying_management is


-- Ürünü sepete ekleyen procedure
PROCEDURE add_to_basket(p_basket_id NUMBER,p_user_id NUMBER,p_product_id NUMBER,p_quantity NUMBER) IS
    v_price NUMBER;
    v_available_quantity NUMBER;
    v_existing_quantity NUMBER;
BEGIN
  
    -- Ürün fiyatýný ve mevcut miktari al
    SELECT price, stock_quantity INTO v_price, v_available_quantity
    FROM Product
    WHERE product_id = p_product_id;

   
    SELECT NVL(quantity, 0) INTO v_existing_quantity
    FROM Basket
    WHERE basket_id = p_basket_id AND user_id = p_user_id AND product_id = p_product_id;

    -- Eðer sepete eklemek istediðimiz miktar ile sepetteki miktar, var olan miktardan küçük eþit ise sepeti güncelle, yani ürünü ekle.
    IF (v_existing_quantity + p_quantity) <= v_available_quantity THEN
        --Sepeti güncelle
        
            UPDATE Basket
            SET quantity = quantity + p_quantity
            WHERE basket_id = p_basket_id AND user_id = p_user_id AND product_id = p_product_id;
            COMMIT;
            
            UPDATE Basket
            SET price = price + p_quantity * v_price
            where basket_id = p_basket_id AND user_id = p_user_id AND product_id = p_product_id;
            commit;
            
            
         
        
        

        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Ürün sepete eklenmistir.');
    ELSE --Eðer var olan miktarý geçiyor isek.
        DBMS_OUTPUT.PUT_LINE('Uzgunuz, yeterli stok miktari yok. Lutfen sepete eklemek istediginiz stok miktarini dusurunuz.');
        ROLLBACK;
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Uzgunuz, belirtilen urun bulunamadi.');
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Urun sepete eklenirken bir hata olustu: ' || SQLERRM);
END add_to_basket;

-- Sepetten çýkaran procedure

PROCEDURE remove_from_basket(
    p_user_id NUMBER,
    p_product_id NUMBER,
    p_quantity NUMBER
) IS

v_quantity NUMBER;
v_basket_id NUMBER;
v_price NUMBER;

BEGIN   
  SELECT quantity,basket_id INTO v_quantity,v_basket_id
  FROM Basket
  where user_id = p_user_id and product_id = p_product_id;
  
  SELECT price INTO v_price 
  FROM Product
  WHERE product_id = p_product_id;
  
  if p_quantity > v_quantity then
    dbms_output.put_line('Sepetinizdeki urunden daha fazla sayida urun cikarilamaz.');
  elsif p_quantity = v_quantity then
    DELETE FROM Basket --Eðer eþitse direk satýrý sil
    WHERE basket_id = v_basket_id and user_id = p_user_id AND product_id = p_product_id; 
    dbms_output.put_line('Urun sepetten cikarilmistir.');
  else 
    update basket --Eþit deðilse quantityi ve priceyi update et.
    set quantity = v_quantity - p_quantity, price = (price - (v_price * p_quantity))
    where user_id = p_user_id and product_id = p_product_id and basket_id = v_basket_id;
    dbms_output.put_line('Urun sepetten cikarilmistir.');
    COMMIT;

 end if;
    

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Ürün sepetten çýkarýlýrken bir hata oluþtu: ' || SQLERRM);
END remove_from_basket;


--Kullanýcýnýn sepetindeki ürünlerini görüntüleyen procedure
   procedure view_basket(p_user_id number) is
    cursor c_basket  is  --Bu cursor, parametre ile verilen kullanýcýnýn sepetindeki ürünleri gezecek
                     select b.basket_id,p.product_name,b.quantity,b.price 
                     FROM Basket b
                     JOIN Product p ON b.product_id = p.product_id  --Bunun için de basketteki product id ile ürünün product idsinin eþleþmesi lazým.
                     WHERE b.user_id = p_user_id; 
                     
     v_basket_row c_basket%ROWTYPE; --C_basket cursorýndan oluþturulmuþ bir record. c_basket cursorý satýr satýr gezerken deðerleri içine fetch
                                                                                                                          --etmek için
begin     
      dbms_output.put_line(p_user_id || ' user IDli kullanýcýnýn sepetindeki ürünler: ');
OPEN c_basket;
    LOOP
        FETCH c_basket INTO v_basket_row;
        EXIT WHEN c_basket%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE('Basket ID: ' || v_basket_row.basket_id ||
                             ', Product Name: ' || v_basket_row.product_name ||
                             ', Quantity: ' || v_basket_row.quantity ||
                             ', Price: ' || v_basket_row.price);
    END LOOP;

    CLOSE c_basket;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Kullanýcýnýn sepeti listelenirken bir hata oluþtu: ' || SQLERRM);
END view_basket;
       
     
PROCEDURE add_to_basket_or_create(p_user_id NUMBER,p_product_id NUMBER,p_quantity NUMBER) IS
    v_basket_id NUMBER;
    v_random_number NUMBER;
    v_id_exists NUMBER;
    v_product_id NUMBER;
BEGIN
    -- Kullanýcýnýn var olan sepetini bul
    SELECT basket_id INTO v_basket_id
    FROM Basket
    WHERE user_id = p_user_id;
    
    


    -- Ürünü sepete ekleyen procedure'ü çaðýr
    if v_basket_id is not null then
      begin
       SELECT product_id into v_product_id -- Sepetin var olma durumunda sepetteki ürünün id'sini alýyoruz.  Bu id, bizim sepete eklemek
                                            -- istediðimiz ürünün idsidir. 
       FROM Basket
       WHERE user_id = p_user_id and basket_id = v_basket_id and product_id = p_product_id;
       
       EXCEPTION
         when no_data_found then -- Eðer ürün sepete ilk defa ekleniyor ise, yani sepette bu ürün yok ise
           INSERT into basket(basket_id,
                         user_id,
                         product_id,
                         quantity,
                         price) values(v_basket_id,p_user_id,p_product_id,0,0); --Sepette yeni satýrý yarat
            COMMIT;
                         
           add_to_basket(p_basket_id  => v_basket_id,  --Sonra da ekleme fonksiyonunu çaðýr
                         p_user_id    => p_user_id,
                         p_product_id => p_product_id,
                         p_quantity   => p_quantity);
       end;
       if v_product_id is not null then --Eðer ürün zaten sepette var ise sadece quantity ve price'yi güncelle.
         
          add_to_basket(p_basket_id => v_basket_id, p_user_id => p_user_id, p_product_id => p_product_id, p_quantity => p_quantity);
       end if;
       
       
       
        
       
    
    end if;
    
    EXCEPTION
        WHEN NO_DATA_FOUND THEN -- Sepet bulunamazsa yeni sepet oluþtur. Aþaðýda yapýlan gereksiz iþlemin çok daha kolay yolu gösterilecektir.
          LOOP
        -- Random sayý oluþtur
        v_random_number := TRUNC(DBMS_RANDOM.VALUE(1, 999999));

        -- Oluþturulan random sayýnýn veritabanýnda var olup olmadýðýný kontrol et
        SELECT COUNT(*) INTO v_id_exists
        FROM basket
        WHERE basket_id = v_random_number;

        -- Eðer ID veritabanýnda yoksa döngüden çýk
        EXIT WHEN v_id_exists = 0;
        END LOOP;
        v_basket_id:= v_random_number;
        INSERT INTO Basket(basket_id,user_id,Product_Id,Quantity) VALUES (v_basket_id,p_user_id,p_product_id,0); --Önce Satýrý yarat
        COMMIT;
        add_to_basket(p_basket_id => v_basket_id, p_user_id => p_user_id, p_product_id => p_product_id, p_quantity => p_quantity); --Sonra da ürünü ekle
    
END add_to_basket_or_create;


-- Satýn alma iþlemini gerçekleþtiren procedure
PROCEDURE buy(p_user_id NUMBER) IS
  
    v_basket_id NUMBER;
    v_purchase_id NUMBER;
    v_purchase_id_exists NUMBER;
    v_purchase_item_id NUMBER;
    v_purchase_item_id_exists NUMBER;
    v_total_price NUMBER;
    TYPE BasketIdList IS TABLE OF Basket.basket_id%TYPE; --Sepetin içinde birden fazla ürün bulunmasý durumunda
    v_basket_ids BasketIdList;
    
BEGIN
    -- Kullanýcýnýn var olan sepetini bul
    SELECT basket_id BULK COLLECT INTO v_basket_ids
    FROM Basket
    WHERE user_id = p_user_id;
    
    v_basket_id := v_basket_ids(1);

   
    if v_basket_id is not null then
        SELECT NVL(SUM(price), 0)
        INTO v_total_price
        FROM Basket
        WHERE basket_id = v_basket_id;
      

    -- Satýn alma iþlemi için yeni bir ID oluþtur
    
      LOOP
      v_purchase_id := TRUNC(DBMS_RANDOM.VALUE(1, 999999));
      
      -- Oluþturulan random sayýnýn veritabanýnda var olup olmadýðýný kontrol et
        SELECT COUNT(*) INTO v_purchase_id_exists
        FROM Purchase
        WHERE purchase_id = v_purchase_id;
        
        EXIT WHEN v_purchase_id_exists = 0;
       END LOOP;
        

      -- Satýn alma iþlemini loglamak için Purchase tablosuna ekle
      INSERT INTO Purchase (Purchase_Id,
                            Purchase_Date,
                            User_Id,
                            Total_Price)
      VALUES (v_purchase_id,SYSDATE, p_user_id, v_total_price);

      -- Sepetteki her ürünü gez
      FOR basket_row IN (SELECT * FROM Basket WHERE basket_id = v_basket_id) LOOP
        LOOP
      v_purchase_item_id := TRUNC(DBMS_RANDOM.VALUE(1, 999999));
      
      -- Oluþturulan random sayýnýn veritabanýnda var olup olmadýðýný kontrol et
        SELECT COUNT(*) INTO v_purchase_item_id_exists
        FROM Purchase_item
        WHERE purchase_item_id = v_purchase_item_id;
        
        EXIT WHEN v_purchase_item_id_exists = 0;
       END LOOP;
      
          -- ve Purchase_Item tablosuna ekle
          INSERT INTO Purchase_Item (purchase_item_id, purchase_id, product_id, quantity, price)
          VALUES (
              v_purchase_item_id,
              v_purchase_id,
              basket_row.product_id,
              basket_row.quantity,
              basket_row.price
          );
          
     
       --Sepetteki satýn alýnan ürünlerin stok miktarýný, product tablosundan çýkar.
            UPDATE Product
            SET stock_quantity = stock_quantity - basket_row.quantity
            WHERE product_id = basket_row.product_id;
            COMMIT;

          --Ve Sepetten ürünü çýkar
          remove_from_basket(p_user_id, basket_row.product_id, basket_row.quantity);
      END LOOP;
          
     end if;
      COMMIT;
      DBMS_OUTPUT.PUT_LINE('Satin alma islemi bsþariyla gerceklesti.');
EXCEPTION
    WHEN no_data_found THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Sepetiniz bos, lutfen satin alma isleminden once sepetinize urun ekleyiniz.');
END buy;
      

--Kullanýcýnýn Geçmiþte Yaptýðý Tüm Alýþveriþlerin Listesini Döndüren Procedure
PROCEDURE view_purchase_history(p_user_id NUMBER) IS
BEGIN
    FOR purchase_row IN (SELECT p.purchase_id,
                                  p.purchase_date,
                                  pi.product_id,
                                  pr.product_name,
                                  pi.quantity,
                                  pi.price
                             FROM Purchase p
                                  JOIN Purchase_Item pi ON p.purchase_id = pi.purchase_id
                                  JOIN Product pr ON pi.product_id = pr.product_id
                            WHERE p.user_id = p_user_id
                            ORDER BY p.purchase_date DESC) LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Purchase ID: ' || purchase_row.purchase_id ||
            ', Purchase Date: ' || TO_CHAR(purchase_row.purchase_date, 'DD.MM.YYYY HH24:MI:SS') ||
            ', Product ID: ' || purchase_row.product_id ||
            ', Product Name: ' || purchase_row.product_name ||
            ', Quantity: ' || purchase_row.quantity ||
            ', Price: ' || purchase_row.price
        );
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Geçmiþ alýþveriþler listelenirken bir hata oluþtu: ' || SQLERRM);
END view_purchase_history;

PROCEDURE export_purchase_history_to_csv(p_user_id NUMBER) IS
    v_file UTL_FILE.FILE_TYPE;

   CURSOR purchase_cursor IS
        SELECT
            p.purchase_id,
            p.user_id,
            pi.product_id,
            pr.product_name,
            pi.quantity,
            p.total_price,
            p.purchase_date
        FROM
            purchase p join purchase_item pi on p.purchase_id = pi.purchase_id JOIN Product pr ON pi.product_id = pr.product_id
        WHERE
            user_id = p_user_id;
BEGIN
    -- Dosya açma iþlemi
    v_file := UTL_FILE.FOPEN('EXPORT_DIR', 'purchase_history.csv', 'W');

    -- Baþlýk satýrýný yazma
    UTL_FILE.PUT_LINE(v_file, 'Purchase ID,User ID,Product ID,Quantity,Total Price,Purchase Date');

    -- Cursor ile purchase tablosunu dolaþma ve dosyaya yazma
    FOR purchase_rec IN purchase_cursor LOOP
        UTL_FILE.PUT_LINE(v_file,
            purchase_rec.purchase_id || ',' ||
            purchase_rec.user_id || ',' ||
            purchase_rec.product_id || ',' ||
            purchase_rec.product_name || ',' ||
            purchase_rec.quantity || ',' ||
            purchase_rec.total_price || ',' ||
            TO_CHAR(purchase_rec.purchase_date, 'DD/MM/YYYY HH24:MI:SS')
        );
    END LOOP;

    -- Dosya kapatma iþlemi
    UTL_FILE.FCLOSE(v_file);
EXCEPTION
    WHEN OTHERS THEN
        -- Hata durumunda dosyayý kapatma ve bilgileri yazdýrma
        IF UTL_FILE.IS_OPEN(v_file) THEN
            UTL_FILE.FCLOSE(v_file);
        END IF;
        
        DBMS_OUTPUT.PUT_LINE('Hata: ' || SQLERRM);
END export_purchase_history_to_csv;

    PROCEDURE add_favourite(p_user_id NUMBER, p_product_id NUMBER) IS
       v_favorite_count NUMBER;
      BEGIN
        -- Eðer product zaten favori olarak eklenmiþse tekrar favourite tablosuna eklemene gerek yok.
        SELECT COUNT(*)
        INTO v_favorite_count
        FROM favorite
        WHERE user_id = p_user_id AND product_id = p_product_id;

  -- Eðer favori tablosunda  bu ürün yoksa favori olarak ekle
  IF v_favorite_count = 0 THEN
    INSERT INTO Favorite (user_id, product_id)
    VALUES (p_user_id, p_product_id);
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Urun favorilere eklendi.');
 end if;
 
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Urun favorilere eklenirken bir hata olustu: ' || SQLERRM);
END add_favourite;


PROCEDURE remove_favorite(
    p_user_id NUMBER,
    p_product_id NUMBER
) IS
BEGIN
    DELETE FROM Favorite
    WHERE user_id = p_user_id AND product_id = p_product_id;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Urun favorilerden cikarildi.');
EXCEPTION
  when no_data_found then
    dbms_output.put_line('Favori olarak ekleyemediginiz urunu favoriden cikarmazsiniz.');
    ROLLBACK;
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Urun favorilerden cikarilirken bir hata olustu: ' || SQLERRM);
END remove_favorite;

PROCEDURE list_favourite_products(p_user_id NUMBER) IS
  
  CURSOR c_products IS
    SELECT
      p.product_id AS product_id, --AS kullanmayýnca alias required in select list of cursor to avoid duplicate column names hatasý verdi.
      p.product_name AS product_name,
      p.price AS price,
      p.stock_quantity AS stock_quantity,
      pc.category_id AS category_id,
      pc.category_name AS category_name
    FROM
      product_category pc
    JOIN
      product p ON pc.category_id = p.category_id
    JOIN
      favorite f ON f.product_id = p.product_id
    WHERE
      f.user_id = p_user_id;
  
  -- Cursoru gezerken atacaðýmýz deðerler için bir record ve ardýndan da bir nested table tanýmlýyoruz. 
  TYPE ProductInfo IS RECORD (              --Recordumuz
    product_id       NUMBER,
    product_name     VARCHAR2(100),
    price            NUMBER,
    stock_quantity   NUMBER,
    category_id      NUMBER,
    category_name    VARCHAR2(100)
  );

  TYPE ProductInfoList IS TABLE OF ProductInfo; --Nested tablemiz, ProductInfo tipinde
  v_product_info_list ProductInfoList := ProductInfoList();

  
  begin 
  dbms_output.put_line('Favori Urunleriniz:');
  
  FOR r_products IN c_products LOOP
    v_product_info_list.EXTEND;  --extendi kullanmayýnca hata verdi.
    v_product_info_list(v_product_info_list.LAST) := --En son indisimize .LAST ile eriþiyoruz ve recordumuzu 
      ProductInfo(
          r_products.product_id,
          r_products.product_name,
          r_products.price,
          r_products.stock_quantity,
          r_products.category_id,
          r_products.category_name
      );
  END LOOP;

  FOR i IN v_product_info_list.first .. v_product_info_list.last LOOP
    DBMS_OUTPUT.PUT_LINE(
      'Product ID: ' || v_product_info_list(i).product_id || ',' ||
      'Product Name: ' || v_product_info_list(i).product_name || ',' ||
      'Price: ' || v_product_info_list(i).price || ',' ||
      'Stock Quantity: ' || v_product_info_list(i).stock_quantity || ',' ||
      'Category ID: ' || v_product_info_list(i).category_id || ',' ||
      'Category Name: ' || v_product_info_list(i).category_name
    );
  END LOOP;
END list_favourite_products;                       
    

end buying_management;
/
