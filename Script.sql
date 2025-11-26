CREATE SCHEMA [OwlForYou2];

CREATE TABLE [OwlForYou2].Goodies (
    GoodieId INT IDENTITY(1,1) PRIMARY KEY,
    GoodieName NVARCHAR(50) NOT NULL
);

CREATE TABLE [OwlForYou2].Colors (
    ColorId INT IDENTITY(1,1) PRIMARY KEY,
    ColorName NVARCHAR(50) NOT NULL
);

CREATE TABLE [OwlForYou2].Sizes (
    SizeId INT IDENTITY(1,1) PRIMARY KEY,
    SizeName NVARCHAR(5) NOT NULL
);

CREATE TABLE [OwlForYou2].Products (
    ProductId INT IDENTITY(1,1) PRIMARY KEY,
    GoodieId INT,
    ColorId INT,
    SizeId INT,
    BasePrice DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (GoodieId) REFERENCES [OwlForYou2].Goodies(GoodieId),
    FOREIGN KEY (ColorId) REFERENCES [OwlForYou2].Colors(ColorId),
    FOREIGN KEY (SizeId) REFERENCES [OwlForYou2].Sizes(SizeId),
    CONSTRAINT UK_Product UNIQUE (GoodieId, ColorId, SizeId)
);


CREATE TABLE [OwlForYou2].Promotions (
    PromoDate DATE PRIMARY KEY,
    PromoDescription NVARCHAR(100)
);

CREATE TABLE [OwlForYou2].PromotionRules (
    RuleId INT IDENTITY(1,1) PRIMARY KEY,
    PromoDate DATE,
    ProductId INT,
    DiscountPercent DECIMAL(5, 2),
    FOREIGN KEY (PromoDate) REFERENCES [OwlForYou2].Promotions(PromoDate),
    FOREIGN KEY (ProductId) REFERENCES [OwlForYou2].Products(ProductId)
);

CREATE TABLE [OwlForYou2].Orders (
    OrderId INT IDENTITY(1,1) PRIMARY KEY,
    OrderDate DATE NOT NULL
);

CREATE TABLE [OwlForYou2].OrderLines (
    LineId INT IDENTITY(1,1) PRIMARY KEY,
    OrderId INT NOT NULL,
    ProductId INT NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(10, 2) NULL, 
    AppliedDiscount DECIMAL(5, 2) NULL, 
    TotalLine DECIMAL(10, 2) NULL, 
    FOREIGN KEY (OrderId) REFERENCES [OwlForYou2].Orders(OrderId),
    FOREIGN KEY (ProductId) REFERENCES [OwlForYou2].Products(ProductId)
);


--trigger
GO
CREATE TRIGGER [OwlForYou2].Trg_CalculateOrderLine
ON [OwlForYou2].OrderLines
AFTER INSERT
AS
BEGIN    
    UPDATE OL
    SET 
        -- Récupération du prix de base
        OL.UnitPrice = P.BasePrice,
        
        --Récupération de la remise 
        OL.AppliedDiscount = ISNULL(PR.DiscountPercent, 0.00),
        
        --Calcul du total : (Prix * (1 - Remise)) * Quantité
        OL.TotalLine = (P.BasePrice * (1.00 - ISNULL(PR.DiscountPercent, 0.00))) * OL.Quantity
        
    FROM [OwlForYou2].OrderLines OL
    INNER JOIN Inserted I ON OL.LineId = I.LineId 
    INNER JOIN [OwlForYou2].Products P ON OL.ProductId = P.ProductId
    INNER JOIN [OwlForYou2].Orders O ON OL.OrderId = O.OrderId
    LEFT JOIN [OwlForYou2].PromotionRules PR ON PR.ProductId = P.ProductId AND PR.PromoDate = O.OrderDate;
END;

-- Remplissage des options
INSERT INTO [OwlForYou2].Goodies (GoodieName) VALUES ('T-Shirt Saint Bé'), ('Sweat Shirt Saint Bé');
INSERT INTO [OwlForYou2].Colors (ColorName) VALUES ('Blue'), ('Red'), ('Black'), ('White'), ('Gray');
INSERT INTO [OwlForYou2].Sizes (SizeName) VALUES ('XS'), ('S'), ('L'), ('XL'), ('XXL');

-- Produits et Prix
INSERT INTO [OwlForYou2].Products (GoodieId, ColorId, SizeId, BasePrice) VALUES 
(1, 1, 4, 10.00), -- T-Shirt Blue XL (Id 1)
(2, 2, 4, 20.00), -- Sweat Red XL   (Id 2)
(1, 1, 3, 9.00),  -- T-Shirt Blue L (Id 3)
(2, 2, 3, 17.00), -- Sweat Red L    (Id 4)
(2, 2, 5, 30.00), -- Sweat Red XXL  (Id 5)
(1, 2, 4, 11.00), -- T-Shirt Red XL (Id 6)
(2, 1, 2, 17.00); -- Sweat Blue S   (Id 7)

-- Dates de promos
INSERT INTO [OwlForYou2].Promotions (PromoDate, PromoDescription) VALUES 
('2020-09-21', 'Back To School'),
('2020-09-22', 'Day After Back To School');

-- Règles de réduction
INSERT INTO [OwlForYou2].PromotionRules (PromoDate, ProductId, DiscountPercent) VALUES
('2020-09-21', 2, 0.10),
('2020-09-21', 3, 0.20),
('2020-09-21', 4, 0.10),
('2020-09-21', 5, 0.30),
('2020-09-22', 1, 0.30),
('2020-09-22', 3, 0.30);



--test

INSERT INTO [OwlForYou2].Orders (OrderDate) VALUES ('2020-09-21');

-- Insertion des lignes

INSERT INTO [OwlForYou2].OrderLines (OrderId, ProductId, Quantity) VALUES 
((SELECT MAX(OrderId) FROM [OwlForYou2].Orders), 1, 1),
((SELECT MAX(OrderId) FROM [OwlForYou2].Orders), 2, 1),
((SELECT MAX(OrderId) FROM [OwlForYou2].Orders), 3, 2), 
((SELECT MAX(OrderId) FROM [OwlForYou2].Orders), 4, 2),
((SELECT MAX(OrderId) FROM [OwlForYou2].Orders), 5, 1); 

-- Vérification du résultat
SELECT 
    O.OrderDate,
    G.GoodieName, 
    C.ColorName, 
    S.SizeName,
    OL.Quantity, 
    OL.UnitPrice, 
    CAST(OL.AppliedDiscount * 100 AS INT) AS DiscountPercent, 
    OL.TotalLine
FROM [OwlForYou2].OrderLines OL
JOIN [OwlForYou2].Products P ON OL.ProductId = P.ProductId
JOIN [OwlForYou2].Goodies G ON P.GoodieId = G.GoodieId
JOIN [OwlForYou2].Colors C ON P.ColorId = C.ColorId
JOIN [OwlForYou2].Sizes S ON P.SizeId = S.SizeId
JOIN [OwlForYou2].Orders O ON OL.OrderId = O.OrderId

WHERE O.OrderId = (SELECT MAX(OrderId) FROM [OwlForYou2].Orders);

GO
CREATE PROCEDURE [OwlForYou2].usp_GetDiscountForProductOnDate
    @ProductId INT,
    @OrderDate DATE,
    @Discount DECIMAL(5,2) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP 1 @Discount = PR.DiscountPercent
    FROM [OwlForYou2].PromotionRules PR
    WHERE PR.ProductId = @ProductId
      AND PR.PromoDate = @OrderDate
    ORDER BY PR.DiscountPercent DESC;  
    IF @Discount IS NULL
        SET @Discount = 0.00;
END;
GO

