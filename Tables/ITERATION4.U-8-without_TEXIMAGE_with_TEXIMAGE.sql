CREATE TABLE [ITERATION4].[U-8-without_TEXIMAGE_with_TEXIMAGE] (
  [col1] [int] NOT NULL,
  [col2] [text] NULL,
  [col3] [ntext] NULL,
  PRIMARY KEY CLUSTERED ([col1])
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO