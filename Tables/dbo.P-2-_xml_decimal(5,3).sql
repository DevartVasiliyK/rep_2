CREATE TABLE [dbo].[P-2-_xml_decimal(5,3)] (
  [pk_int] [int] NOT NULL,
  [comp_xml_decimal(5,3)] [xml] NULL,
  PRIMARY KEY CLUSTERED ([pk_int])
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO