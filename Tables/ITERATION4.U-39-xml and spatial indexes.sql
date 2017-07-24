CREATE TABLE [ITERATION4].[U-39-xml and spatial indexes] (
  [col1] [int] NOT NULL,
  [col2] [xml] NULL,
  PRIMARY KEY CLUSTERED ([col1])
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO

SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PRIMARY XML INDEX [U-39- xml and spatial indexes]
  ON [ITERATION4].[U-39-xml and spatial indexes] ([col2])
  WITH (FILLFACTOR = 1)
GO