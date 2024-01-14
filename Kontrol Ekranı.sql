-----Kontrol Ekraný----------

insert into regions values (1,'Middle Europe');
insert into regions values (2,'West Europe');
insert into regions values (3,'East Europe');
insert into regions values (4,'Asia');
insert into regions values (5,'Middle East');
insert into regions values (6,'Far East');


insert into countries values(93,'Afghanistan',5);
insert into countries values(964, 'Iraq',5);
insert into countries values(49,'Germany',1);
insert into countries values(90,'Turkey',4);
insert into countries values(81,'Japan',6);
insert into countries values(43,'Austria',1);
insert into countries values(44,'United Kingdom',2);
insert into countries values(355,'Albania',3);



INSERT INTO Product_Category (category_id, category_name, parent_category_id) VALUES (1, 'Giyim', NULL);
INSERT INTO Product_Category (category_id, category_name, parent_category_id) VALUES (2, 'Üst Giyim', 1);
INSERT INTO Product_Category (category_id, category_name, parent_category_id) VALUES (3, 'Alt Giyim', 1);
INSERT INTO Product_Category (category_id, category_name, parent_category_id) VALUES (4, 'Aksesuarlar', 1);
INSERT INTO Product_Category (category_id, category_name, parent_category_id) VALUES (5, 'Ayakkabý', NULL);
INSERT INTO Product_Category (category_id, category_name, parent_category_id) VALUES (6, 'Spor Ayakkabý', 4);
INSERT INTO Product_Category (category_id, category_name, parent_category_id) VALUES (7, 'Klasik Ayakkabý', 4);
INSERT INTO Product_Category (category_id, category_name, parent_category_id) VALUES (8, 'Botlar_ve_cizmeler', 4);






begin
  user_management_pkg.create_user(p_user_id      => 1,
                                  p_username     => 'o.Atay',
                                  p_email        => 'oguz_atay@outlook.com',
                                  p_gender       => 'Male',
                                  p_password     => 'oatay',
                                  p_name         => 'Oguz',
                                  p_surname      => 'Atay',
                                  p_address_id   => 1,
                                  p_phone_number => '905323656538',
                                  p_street       => 'Ayazaga Sokak',
                                  p_city         => 'Istanbul',
                                  p_state        => 'Marmara',
                                  p_postal_code  => '34000',
                                  p_country_id   => 90);
end;

begin 
      user_management_pkg.create_user(p_user_id      => 2,
                                      p_username     => 'Hideo',
                                      p_email        => 'hkojima@outlook.com',
                                      p_gender       => 'Male',
                                      p_password     => 'hkojima',
                                      p_name         => 'Hideo',
                                      p_surname      => 'Kojima',
                                      p_address_id   => 2,
                                      p_phone_number => '815430569521',
                                      p_street       => 'Hidetaka',
                                      p_city         => 'Tokyo',
                                      p_state        => 'Middle Japan',
                                      p_postal_code  => '81000',
                                      p_country_id   => '81');
      
      user_management_pkg.create_user(p_user_id      => 3,
                                      p_username     => 't_Hans',
                                      p_email        => 'hans@gmail.com',
                                      p_gender       => 'Male',
                                      p_password     => '123456',
                                      p_name         => 'Tom',
                                      p_surname      => 'Hans',
                                      p_address_id   => 3,
                                      p_phone_number => '491039504920',
                                      p_street       => 'Hans Street',
                                      p_city         => 'Munich',
                                      p_state        => 'Middle Germany',
                                      p_postal_code  => 49000,
                                      p_country_id   => 49);


end;

select * from user_details
begin
  user_management_pkg.change_password_via_email(p_email => 'oguz_atay@outlook.com', p_new_password =>'asdsada' );
end;

select * from product
select * from product_category


begin
 -- user_management_pkg.user_login(p_username => 'o.Atay', p_password =>'oatay');
--user_management_pkg.change_password_via_email(p_email => 'oguz_atay1@outlook.com', p_new_password =>'asdsada' );
  --user_management_pkg.user_login(p_username => 'o.Atay', p_password =>'asdsada');
   --user_management_pkg.change_password_via_email(p_email => 'oguz_atay@outlook.com', p_new_password =>'oatay' );
  --product_management.add_item; --50 product eklendi db'ye.
  --product_management.list_products_by_price_asc --> artan sýrada tüm ürünleri listeleyen procedure.
 -- product_management.list_products_by_price_desc --> azalan sýrada tüm ürünleri listeleyen procedure.
 --product_management.list_products_by_category_price_asc(p_category_id => 6); -->Örneðin tüm spor ayakkabýlarýný artan fiyatta listelesin
 --product_management.list_products_by_category_price_desc(p_category_id => 4); --> Tüm aksesuarlarý azalan fiyatta listelesin.
-- product_management.add_product(p_product_id     => 51,p_product_name   => 'Altýn Kolye', p_price=> 7500, p_stock_quantity => 10,p_category_id => 4);
--product_management.remove_product(p_product_id => 51); --> Altýn kolyeyi kaldýralým.   
    
/*buying_management.add_to_basket_or_create(p_user_id    => 3,
                                          p_product_id => 1,
                                          p_quantity   => 100); -- 90 tane olan spor ayakkabýsý1'den 100 tane almaya çalýþalým. Uyarý mesajý görmeyi bekliyoruz. */            
                               
 

/*buying_management.add_to_basket_or_create(p_user_id    => 3,
                                          p_product_id => 1,
                                          p_quantity   => 80); --spor ayakkabýsý1'den 80 tane sepete eklesin Hans. */
                                          
/*buying_management.add_to_basket_or_create(p_user_id    => 3, --Bot2'den 10 tane sepete eklesin Hans.
                                          p_product_id => 2,
                                          p_quantity   => 10); */
                                          
/*buying_management.remove_from_basket(p_user_id    => 3,     --spor ayakkabýsý1'den 78 tane kaldýralým 2 tane kalmasýný bekliyoruz.
                                     p_product_id => 1,
                                     p_quantity   => 78); */
                                    

/*buying_management.remove_from_basket( p_user_id    => 3,  --Bot2'nin hepsini(10) sepetten çýkaralým. Hansýn sepetinde sadece 2 tane spor ayakkabýsý1 kalmalý.
                                      p_product_id => 2,
                                      p_quantity   => 10); */    
                                      
--buying_management.view_basket(p_user_id => 3) --Hansýn sepetini görüntüleyelim.  

/* buying_management.remove_from_basket(p_user_id    => 3,
                                     p_product_id => 1,
                                     p_quantity   => 2) */ --Hans'ýn sepetini boþaltalým.
                                    
--buying_management.buy(p_user_id => 3); --Önce sepetinde ürün olmayan kullanýcý satýn almaya çalýþsýn. Uyarý vermesini bekliyoruz.   

/*buying_management.add_to_basket_or_create(p_user_id    => 1,
                                          p_product_id => 4,
                                          p_quantity   => 10); --Oðuz Atay, Aksesuar 4'ten 10 tane alsýn. */
                                         

--buying_management.buy(p_user_id => 1); --Ve bunlarý satýn alsýn.                            
 
/*buying_management.add_to_basket_or_create(p_user_id    => 1,
                                          p_product_id => 1,
                                          p_quantity   => 10); --Þimdi de Oðuz Atay, sepetine Spor Ayakkabýsý 1'den 10 tane eklesin */
                                          

                   
--buying_management.buy(p_user_id => 1); --Ve bunlarý satýn alsýn. 

--buying_management.view_purchase_history(p_user_id => 1); --Oðuz Atay'In geçmiþte aldýðý ürünlerin listesi.


/*buying_management.add_to_basket_or_create(p_user_id    => 2,       --Hideo Kojima, Ürün5'ten 10 tane ve Aksesuar6'dan 5 tane sepete eklesin.
                                          p_product_id => 5,
                                          p_quantity   => 10); */
 
/*buying_management.add_to_basket_or_create(p_user_id    => 2,
                                          p_product_id => 6,
                                          p_quantity   => 5); */
                                          

--buying_management.buy(p_user_id => 2);                 --Ve Hideo Kojima, sepetindeki ürünleri satýn alsýn. 
--buying_management.view_purchase_history(p_user_id => 2); --Hideo Kojima'nýn yaptýðý alýþveriþ. Ürün bazýnda
--buying_management.export_purchase_history_to_csv(p_user_id => 2); Hideo Kojima'nýn yaptýðý alýþveriþleri csv dosyasýna yazalým.
/*buying_management.add_to_basket_or_create(p_user_id    => 3,
                                          p_product_id => 13,
                                          p_quantity   => 11); */ --Hans, Spor Ayakkabýsý 13'ten 11 tane alsýn.
                                          
/*buying_management.add_to_basket_or_create(p_user_id    => 3,
                                          p_product_id => 13,
                                          p_quantity   => 5); */ -- Hans, Spor Ayakkabýsý 13'ten 5 tane ve Aksesuar 9'dan 7 tane alsýn.    
                                          
/*buying_management.add_to_basket_or_create(p_user_id    => 3,
                                          p_product_id => 9,
                                          p_quantity   => 7);  */

--buying_management.add_favourite(p_user_id => 3, p_product_id =>11 );--Hans, favori olarak Bot11'i eklesin.                                                                            
 
--buying_management.add_favourite(p_user_id => 1, p_product_id =>17 ); --Oðuz Atay, favori olarak Pantolon17'yi eklesin.
--buying_management.add_favourite(p_user_id => 1, p_product_id =>46 ); --Oðuz Atay, favori olarak Ürün 46'yý eklesin.

--buying_management.list_favourite_products(p_user_id =>1); --Oðuz Atay'ýn favori listesini görelim.

--buying_management.buy(p_user_id => 3); -- Hans, sepetindeki spor ayakkabýsý13'ten 11 tane + 5 tane ve aksesuar9'dan 7 tane yi alsýn.
--product_management.most_sold_products; --En çok satýlan ürünleri görelim En çok 16 tane Spor Ayakkabýsý-13'ü görmemiz lazým.

end;



select * from basket
select * from product
select * from user_definition
select * from purchase
select * from purchase_item
select * from favorite

drop table basket;
drop table purchase;
drop table purchase_item;
drop table favorite;

