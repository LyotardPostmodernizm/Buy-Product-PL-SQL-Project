create or replace package user_management_pkg is
    -- Kullanýcý tanýmlama proc
    procedure create_user(
        p_user_id NUMBER,
        p_username VARCHAR2,
        p_email varchar2,
        p_gender varchar2,
        p_password VARCHAR2
    );

    -- Kullanýcý giriþi kontrolü proc
    procedure check_login(p_username varchar2, p_password varchar2);

    -- Hashing fonksiyonu
    function hash_password(p_password varchar2) return varchar2;
    
end user_management_pkg;
/ --package speci bitiyor


    -- Þifre hash fonksiyonu
    function hash_password(p_password varchar2) return varchar2 is
        v_salt varchar2(16) := DBMS_RANDOM.STRING('x', 16);
    begin
        return DBMS_CRYPTO.HASH(p_password || v_salt, DBMS_CRYPTO.HASH_SH256) || v_salt;
    end hash_password;




create or replace package body user_management_pkg is
    --Kullanýcý yaratma proc
    procedure create_user(p_user_id number,p_username varchar2,p_email varchar2,p_gender varchar2,p_password varchar2) is
        v_password_hash varchar2(16);
        
    begin
      v_password_hash := hash_password(p_password);

        -- Kullanýcýyý ekle
        insert into user_definition(user_id, username,email, gender, password_hash, last_login_date) values (p_user_id, p_username,
        p_email,p_gender, v_password_hash, sysdate);
    end create_user;
    

    -- Kullanýcý giriþi kontrolü proc
    procedure check_login(p_username varchar2, p_password varchar2) is
        v_stored_password_hash user_definition.password_hash%TYPE;
        v_salt VARCHAR2(16);
    BEGIN
        -- Kullanýcý adýna göre þifre hash ve salt'ýný al
        SELECT password_hash INTO v_stored_password_hash
        FROM user_definition
        WHERE username = p_username;

        -- Þifreyi kontrol et
        if hash_password(p_password) = v_stored_password_hash then
            -- Baþarýlý giriþ
            UPDATE user_definition
            SET login_attempts = 0,last_login_date = SYSDATE
            WHERE username = p_username;
            DBMS_OUTPUT.PUT_LINE('Giriþ Baþarýlý');
        else
            -- Hatalý giriþ
            UPDATE user_definition
            SET login_attempts = login_attempts + 1
            WHERE username = p_username;

            IF login_attempts >= 3 THEN
                -- Kullanýcýyý kilitli hale getir
                UPDATE user_definition
                SET is_locked = 1
                WHERE username = p_username;
                DBMS_OUTPUT.PUT_LINE('Hesap kilitlendi. Þifrenizi sýfýrlayýn.');
            ELSE
                DBMS_OUTPUT.PUT_LINE('Hatalý Giriþ. Kalan Deneme Hakkýnýz: ' || (3 - login_attempts));
            END IF;
        END IF;
    END check_login;


    
end user_management_pkg;
/
