CREATE PARTITION FUNCTION [U-7-Русская функция] ([char](20))
  AS RANGE FOR VALUES ('Русс. знач          ', 'Русс-е зн-е         ')
GO