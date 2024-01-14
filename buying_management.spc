create or replace package buying_management is
       PROCEDURE add_to_basket(p_basket_id NUMBER,p_user_id NUMBER,p_product_id NUMBER,p_quantity NUMBER);

end buying_management;
/
