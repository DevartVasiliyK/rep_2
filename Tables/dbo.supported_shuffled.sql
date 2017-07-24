CREATE TABLE [dbo].[supported_shuffled] (
  [clm_sysname] [sysname] NOT NULL,
  [clm_char_50] [char](50) NULL,
  [clm_varchar_050] [varchar](50) NULL,
  [clm_varchar_max] [varchar](max) NULL,
  [clm_text] [text] NULL,
  [clm_nchar_50] [nchar](50) NULL,
  [clm_nvarchar_050] [nvarchar](50) NULL,
  [clm_nvarchar_max] [nvarchar](max) NULL,
  [clm_ntext] [ntext] NULL,
  [clm_sql_variant] [sql_variant] NULL
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO