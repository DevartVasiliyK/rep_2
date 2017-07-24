CREATE TABLE [dbo].[P-2-_ntext_binary] (
  [pk_int] [int] NOT NULL,
  [comp_ntext_binary] [ntext] NULL,
  PRIMARY KEY CLUSTERED ([pk_int])
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO