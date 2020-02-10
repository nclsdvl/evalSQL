------------------------------------------------------------------------------------------------------------
-- 0 . creer la base de données "data" et la table "client_0" comportant toutes les variables sauf la dernière
------------------------------------------------------------------------------------------------------------


create database if not exists data;


use data;

CREATE TABLE client_0 (
    id INT,
    shipping_mode VARCHAR(255),
    shipping_price VARCHAR(255),
    warranties_flg VARCHAR(10),
    warranties_price VARCHAR(10),
    card_payment INT(10),
    coupon_payment INT (10),
    rsp_payment int(10),
    wallet_payment int(10),
    priceclub_status VARCHAR(255),
    registration_date INT(10),
    purchase_count VARCHAR(100),
    buyer_birthday_date float(6, 1),
    buyer_departement int(5),
    buying_date VARCHAR(100),
    seller_score_count VARCHAR(100),
    seller_score_average float(6,1),
    seller_country VARCHAR(255),
    seller_departement int(10),
    product_type VARCHAR(255),
    product_family VARCHAR(255),
    item_price VARCHAR(255),
    cle VARCHAR(255)
);


LOAD DATA LOCAL INFILE 'D:\Base_eval.csv'
INTO TABLE client_0
FIELDS TERMINATED BY ';' 
LINES TERMINATED BY '\n'
ignore 1 LINES;

------------------------------------------------------------------------------------------------------------
-- 1. combien de doublons avons-nous 
------------------------------------------------------------------------------------------------------------

SELECT count(id), id, item_price, product_family, product_type, buying_date, buyer_birthday_date, purchase_count
FROM client_0
group by id, item_price, product_family, product_type, buying_date, buyer_birthday_date, purchase_count
HAVING COUNT(*) > 1;

---> 9669 doublons



------------------------------------------------------------------------------------------------------------
-- 2. supprimer les doublons
------------------------------------------------------------------------------------------------------------
ALTER IGNORE TABLE client_0 ADD UNIQUE INDEX(id, item_price, product_family, product_type, buying_date, buyer_birthday_date, purchase_count); 

------------------------------------------------------------------------------------------------------------
-- 3. combien de vendeurs étrangers avons-nous 
------------------------------------------------------------------------------------------------------------

select count(*) from client_0
 where not locate( "FRANCE" ,upper(seller_country)) and not locate ("MARTINIQUE", upper(seller_country));
--> 42316


 ------------------------------------------------------------------------------------------------------------
-- 4. creer la table vendeur1 composée des vendeurs étrangers, la table vendeur2 composée des vendeurs français 
--    et la table vendeur3 composées des vendeurs français basés en métropole
------------------------------------------------------------------------------------------------------------

-- Il n'y a que martinique pour la france non - metropolitaine, je n'ai trouvé aucun departement superieur a 99 ou inferieur à 0 avec le terme france
-- et j'ai testé guadeloupe, Réunion, Polynesie, mayotte, nouvelle-caledonie et guyane... dans la colonne seller country --> pas de resultat
-- il n'y a donc que la Martinique qui à 6 entrées.


CREATE TABLE `vendeur1` AS (
    SELECT * FROM client_0
    where not locate( "FRANCE" ,upper(seller_country)) and not locate ("MARTINIQUE", upper(seller_country))
);
--> 42316 Lignes

CREATE TABLE `vendeur2` AS (
    SELECT * FROM client_0
    where locate( "FRANCE" ,upper(seller_country)) or locate ("MARTINIQUE", upper(seller_country))
);
--> 57689 lignes

CREATE TABLE `vendeur3` AS (
    SELECT * FROM client_0
    where locate( "FRANCE_ METROPOLITAN" ,upper(seller_country))
);
--> 57683 Lignes


------------------------------------------------------------------------------------------------------------
-- 5. quelle est la probabilité pour un vendeur français d'avoir un bon score si la vente a lieu un lundi
------------------------------------------------------------------------------------------------------------

--> On à que le mois et pas le jour de vente...
--> qu'est-ce qu'un bon score? ( > à la moyenne ?)
--> je ne sais pas quoi répondre.



------------------------------------------------------------------------------------------------------------
-- 6. quel est le montant total des articles vendus par famille de produits
------------------------------------------------------------------------------------------------------------

-- recupération des plages de nombre d'objets achetés :

SELECT distinct purchase_count FROM `client_0`;

-- <5           = 2
-- 50<100       = 75
-- >500         = 750
-- 5<20         = 13
-- 100<500      = 300
-- 20<50        = 35


-- recupération des plages de prix :

SELECT distinct item_price FROM `client_0` ;


-- <10          = 5
-- 50<100       = 75
-- 1000<5000    = 3000
-- 100<500      = 300
-- 10<20        = 15
-- 20<50        = 35
-- 500<1000     = 750
-- 200          = 200
-- 5            = 5
-- 750          = 750
-- 75           = 75
-- 350          = 350
-- >5000        = 7000

SELECT product_family, sum(
	CASE purchase_count
        when  "<5" THEN 2
        WHEN  "50<100" then 75
        WHEN  ">500" then 750
        WHEN  "5<20" then 13
        when "100<500" then 300
        WHEN  "20<50" THEN 35 
        end)
     *(
    CASE item_price
    	when  "<10" then 5
        WHEN "50<100" then 75
        WHEN "1000<5000" then 3000
        WHEN  "100<500" then 300
		WHEN  "10<20" THEN 15
        WHEN "20<50" THEN 35
		WHEN "500<1000" THEN 750
        WHEN  "200" THEN 200
        WHEN "5" THEN 5
        WHEN "750" THEN 750
        WHEN  "75" THEN 75
        WHEN "350" THEN 350
        WHEN ">5000" THEN 7000
	END) as 'montant total'
FROM `client_0`
group by 1


-- product_family	montant total 	
-- BABY 	        681795
-- BOOKS 	        15925020
-- CLOTHING 	    27733650
-- COMPUTER 	    63279300
-- ELECTRONICS 	    4123120
-- GAMES 	        2727730
-- HIFI 	        47006100
-- MUSIC 	        5227385
-- SPORT 	        9159450
-- VIDEO 	        333754500
-- WHITE 	        23780625
-- WINE 	        127420



------------------------------------------------------------------------------------------------------------
-- 7. Entre nationaux et étrangers qui sont ceux qui ont le plus vendu d'articles
------------------------------------------------------------------------------------------------------------

-- a. nationaux :
SELECT   sum(
	CASE purchase_count
        when  "<5" THEN 2
        WHEN  "50<100" then 75
        WHEN  ">500" then 750
        WHEN  "5<20" then 13
        when "100<500" then 300
        WHEN  "20<50" THEN 35 
        end)
FROM vendeur1

-- 2965205

-- b. etranger :
SELECT   sum(
	CASE purchase_count
        when  "<5" THEN 2
        WHEN  "50<100" then 75
        WHEN  ">500" then 750
        WHEN  "5<20" then 13
        when "100<500" then 300
        WHEN  "20<50" THEN 35 
        end)
FROM vendeur2

-- 5086405


SELECT (
    SELECT   sum(
		CASE purchase_count
            when  "<5" THEN 2
            WHEN  "50<100" then 75
            WHEN  ">500" then 750
            WHEN  "5<20" then 13
            when "100<500" then 300
            WHEN  "20<50" THEN 35 
        end)
	FROM vendeur1)
    -
    (SELECT   sum(
		CASE purchase_count
            when  "<5" THEN 2
            WHEN  "50<100" then 75
            WHEN  ">500" then 750
            WHEN  "5<20" then 13
            when "100<500" then 300
            WHEN  "20<50" THEN 35 
           end)
    FROM vendeur2)

--  -2121200

-- Les étrangers ont vendu 2.121.200 produit de plus que les nationaux.


------------------------------------------------------------------------------------------------------------
-- 8. Créer la table produit_1 (à partir de la table vendeur1) comportant le montant des types de produits par famille de produits
------------------------------------------------------------------------------------------------------------


CREATE TABLE `produit_1` AS (
    SELECT product_family, product_type, item_price FROM `vendeur1` GROUP by 1,2,3
);

-- 530 lignes

------------------------------------------------------------------------------------------------------------
-- 9. Créer la table produit_2 (à partir de la table vendeur2) comportant le montant des types de produits par famille de produits
------------------------------------------------------------------------------------------------------------
CREATE TABLE `produit_2` AS (
   SELECT product_family, product_type, item_price FROM `vendeur2` GROUP by 1,2,3
);

-- 602 lignes

------------------------------------------------------------------------------------------------------------
-- 10. Créer la table produits (à partir des tables vendeur1 & vendeur2) comportant le montant des types de produits par famille de produits : pas de doublons svp
------------------------------------------------------------------------------------------------------------

CREATE TABLE `produits` AS 
    SELECT * FROM produit_1 
    UNION 
    SELECT * FROM produit_2 
    order by product_family, product_type

-- 659 lignes

------------------------------------------------------------------------------------------------------------
-- 11. En considérant que le deuxième achat effectué par un client constitue un complément d'achat et non un doublon, 
--     l'entreprise vous demande de créer à partir du fichier csv de départ une nouvelle table nommée vente_finale 
--     en affichant pas les ventes complémentaires. Toutefois les montants affectés à ces ventes doivent figurer dans la nouvelles table.

--      Exemple :

--          Ancien table :

--              67 RECOMMANDE False 1 0 0 0 UNSUBSCRIBED 2007 <5 1968.0 33 juil-17 1000<10000 44.0 HONG KONG -1 CELLPHONE ELECTRONICS 100<500

--              67 RECOMMANDE False 1 0 0 0 UNSUBSCRIBED 2007 <5 1968.0 33 juil-17 1000<10000 44.0 HONG KONG -1 CELLPHONE ELECTRONICS 200

--          Nouvelle table :

--              67 RECOMMANDE False 1 0 0 0 UNSUBSCRIBED 2007 <5 1968.0 33 juil-17 1000<10000 44.0 HONG KONG -1 CELLPHONE ELECTRONICS 300<700
------------------------------------------------------------------------------------------------------------
