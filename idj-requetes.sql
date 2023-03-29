-- ---------------------------------------------------------------------
-- 1.	Affichage de l’image du jour : obtenir l’information sur une image 
-- pour un jour donné.
-- ---------------------------------------------------------------------
SELECT * FROM image WHERE jour='2023-03-15';

-- ---------------------------------------------------------------------
-- 1.	2.	« Remonter » à la première image du jour dans l’application : 
-- obtenir le jour de la première image disponible (c’est-à-dire la plus 
-- ancienne image du jour).
-- ---------------------------------------------------------------------
SELECT MIN(jour) FROM image;

-- ---------------------------------------------------------------------
-- 3.	Afficher l’état du plébiscite pour l’image et l’utilisateur 
-- courant : obtenir le plébiscite de l’image associée à un jour donné 
-- pour un utilisateur donné.
-- ---------------------------------------------------------------------
SELECT COUNT(plebiscite.id) AS etatAime
    FROM image 
      LEFT JOIN plebiscite ON image.id = image_id 
      LEFT JOIN utilisateur ON utilisateur.id = utilisateur_id 
    WHERE jour='2023-03-15' AND utilisateur.id=10;
-- Note : Essayez les utilisateurs dont les id sont 10 et 735.

-- ---------------------------------------------------------------------
-- 4.	Afficher le nombre de plébiscite de l’image du jour : obtenir le 
-- nombre de plébiscite pour l’image d’un jour donné ;
-- ---------------------------------------------------------------------
SELECT COUNT(p.id) AS compteAime
    FROM image AS i
      LEFT JOIN plebiscite AS p ON i.id = image_id 
      LEFT JOIN utilisateur AS u ON u.id = utilisateur_id 
    WHERE jour='2023-03-15';

-- ---------------------------------------------------------------------
-- 5.	[difficile] Afficher les commentaires de l’image du jour : obtenir 
-- l’ensemble de l’information sur les commentaires (et le décompte des 
-- votes approbateurs/désapprobateurs associés) pour l’image d’un jour 
-- donné.
-- ---------------------------------------------------------------------
SELECT 
  c.*, 
  SUM(CASE WHEN v.updown=1 THEN 1 ELSE 0 END) AS approbateurs, 
  SUM(CASE WHEN v.updown=-1 THEN 1 ELSE 0 END) AS desapprobateurs 
    FROM commentaire AS c 
      JOIN vote AS v ON c.id=v.commentaire_id 
      JOIN image AS i ON c.image_id= i.id 
    WHERE i.jour = '2023-03-15' 
    GROUP by c.id;
-- Remarque : on peut abbrévier l'expression de la somme des votes comme
-- ça : SUM(updown=1) ou SUM(updown=-1). C'est assez logique, pensez-y, 
-- en vous rappelant que les valeurs de vérité en SQL sont 0 pour faux 
-- et 1 pour vrai.

-- ---------------------------------------------------------------------
-- 6.	Afficher les pseudos des utilisateurs ayant aimé une image : 
-- obtenir tous les pseudos ayant des plébiscites pour une image d’un 
-- jour donné.
-- ---------------------------------------------------------------------
SELECT 
  u.pseudo
    FROM utilisateur AS u 
      JOIN plebiscite AS p ON p.utilisateur_id = u.id  
      JOIN image AS i ON p.image_id = i.id 
    WHERE i.jour = '2023-03-15';

-- ---------------------------------------------------------------------
-- 7.	Afficher les 3 images les plus plébiscitées à ce jour : obtenir 
-- l’information sur les 3 images qui ont reçu le plus grand nombre de 
-- plébiscites.
-- ---------------------------------------------------------------------
SELECT 
  i.*, COUNT(p.image_id) AS compteAime
    FROM plebiscite as p 
      JOIN image as i ON p.image_id = i.id 
    GROUP BY i.id 
    ORDER BY compteAime DESC 
    LIMIT 3;
-- Note : remarquez qu'on peut aussi (plus correctement) ne pas mettre 
-- la colonne d'agrégat compteAime dans la liste des champs sélectionnés, 
-- mais uniquement dans la clause ORDER BY (comme certains parmi vous 
-- ont fait)

-- ---------------------------------------------------------------------
-- 8.	[difficile] Afficher uniquement les commentaires ayant un 
-- différentiel de votes positif pour une image d’un jour donné : 
-- obtenir les commentaires associés à une image d’un jour donné pour 
--lesquels la différence entre la somme des votes approbateurs et la 
-- somme des votes désapprobateurs est positive.
-- ---------------------------------------------------------------------
SELECT 
  c.*, 
  (SUM(updown=1) - SUM(updown=-1)) AS differentielVote  
    FROM commentaire AS c 
      JOIN vote AS v ON c.id=v.commentaire_id 
      JOIN image AS i ON c.image_id= i.id 
    WHERE i.jour = '2023-03-15' 
    GROUP by c.id 
    HAVING differentielVote > 0;
-- Note : j'ai abbrévié l'expression CASE par une expression de 
-- comparaison, comme expliqué à la remarque de la question 5.
-- Remarque : on utilise HAVING au lieu de WHERE car on ne peut filtrer
-- une colonne d'agrégat avec WHERE.

-- ---------------------------------------------------------------------
-- 9.	Afficher la date dans le format JJ/MM/AAAA pour une image d’un 
-- jour donné : obtenir l’information sur l’image du jour en formatant 
-- la date avec une fonction MySQL.
-- ---------------------------------------------------------------------
SELECT *, DATE_FORMAT(jour, '%d/%m/%Y') AS dateFormatee
    FROM image WHERE jour = '2023-03-15';

-- ---------------------------------------------------------------------
-- 10.	[difficile][Pas une fonctionnalité du site publique, mais d’un 
-- hypothétique tableau de bord administrateur] : obtenir la liste des 
-- utilisateurs ayant fait des commentaires, et le nombre total de votes 
-- désapprobateurs qu’ils ont reçu, classée en ordre décroissant de ce 
-- nombre.
-- ---------------------------------------------------------------------
SELECT 
  u.id,
	u.pseudo, 
  SUM(CASE WHEN v.updown=-1 THEN 1 ELSE 0 END) AS nbTotalVotesDesapprobateurs 
    FROM utilisateur AS u 
        JOIN commentaire AS c ON u.id = c.utilisateur_id 
        JOIN vote AS v ON c.id = v.commentaire_id 
      GROUP BY u.id
      ORDER BY nbTotalVotesDesapprobateurs DESC;
-- Remarque : finalement cette requête s'est révélée être plus facile 
-- que je ne pensais... 
-- Note : important ici de grouper par utilisateur !
-- Note : comme ci-dessus, on peut remplacer l'expression CASE avec une 
-- expression contenant une comparaison (dont la valeur ne peut être 
-- que 0 ou 1 ;-))