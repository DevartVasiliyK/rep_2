CREATE TABLE [dbo].[P-2-_xml_bit] (
  [pk_int] [int] NOT NULL,
  [comp_xml_bit] [xml] NULL,
  PRIMARY KEY CLUSTERED ([pk_int])
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO