USE [WHJHNativeWebDB]
GO

-- V1.1.7 ��Ϸ���� ����ֶ��޸�
ALTER TABLE [dbo].[GameRule] DROP CONSTRAINT [DF_GameRule_KindIntro]
ALTER TABLE [dbo].[GameRule] ALTER COLUMN [KindIntro] NVARCHAR(MAX) NOT NULL
ALTER TABLE [dbo].[GameRule] ADD CONSTRAINT [DF_GameRule_KindIntro] DEFAULT (N'') FOR [KindIntro]
GO

-- V1.1.7 ���������������
 -- ����
IF EXISTS (SELECT 1
FROM [DBO].SYSObjects
WHERE ID = OBJECT_ID(N'[dbo].[Question]') AND OBJECTPROPERTY(ID,'IsTable')=1 )
BEGIN
  DROP TABLE [dbo].[Question]
END

/****** Object:  Table [dbo].[Question]    Script Date: 2018/1/25 10:57:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Question](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[QuestionTitle] [nvarchar](128) NOT NULL CONSTRAINT [DF_Question_QuestionTitle]  DEFAULT (N''),
	[Answer] [nvarchar](256) NOT NULL CONSTRAINT [DF_Question_Answer]  DEFAULT (N''),
	[SortID] [int] NOT NULL CONSTRAINT [DF_Question_SortID]  DEFAULT ((0)),
	[UpdateAt] [datetime] NOT NULL CONSTRAINT [DF_Question_UpdateAt]  DEFAULT (getdate()),
 CONSTRAINT [PK_Question] PRIMARY KEY CLUSTERED
(
	[ID] ASC,
	[QuestionTitle] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'�ʴ��ʶ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Question', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'����' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Question', @level2type=N'COLUMN',@level2name=N'QuestionTitle'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'��' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Question', @level2type=N'COLUMN',@level2name=N'Answer'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'����ʱ��' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Question', @level2type=N'COLUMN',@level2name=N'UpdateAt'
GO

 -- ����Ĭ������
SET IDENTITY_INSERT [dbo].[Question] ON
INSERT [dbo].[Question] ([ID], [QuestionTitle], [Answer], [SortID]) VALUES (1, N'��λ�ȡ������', N'����ϵ�ͷ���12345678', 1)
INSERT [dbo].[Question] ([ID], [QuestionTitle], [Answer], [SortID]) VALUES (2, N'��λ�ȡ��ʯ��', N'����ϵ�ͷ���12345678', 2)
INSERT [dbo].[Question] ([ID], [QuestionTitle], [Answer], [SortID]) VALUES (3, N'�����ϵ�ͷ���', N'����ϵ�ͷ���12345678', 3)
INSERT [dbo].[Question] ([ID], [QuestionTitle], [Answer], [SortID]) VALUES (4, N'��λ�ȡ��Ϸ�ң�', N'����ϵ�ͷ���12345678', 4)
SET IDENTITY_INSERT [dbo].[Question] OFF


USE [WHJHPlatformManagerDB]
GO
-- V1.1.7 ��̨���������������ģ��
  -- �����µ�ģ��
DELETE DBO.Base_Module WHERE ModuleID = 405
INSERT DBO.Base_Module (ModuleID,ParentID,Title,Link,OrderNo,Nullity,IsMenu,[Description],ManagerPopedom)
VALUES (405,3,N'��������',N'/Module/WebManager/QuestionList.aspx',9,0,0,N'',0)
GO
  -- ������ģ���Ȩ��
DELETE DBO.Base_ModulePermission WHERE ModuleID = 405
INSERT INTO DBO.Base_ModulePermission ([ModuleID] ,[PermissionTitle] ,[PermissionValue] ,[Nullity] ,[StateFlag] ,[ParentID])
VALUES (405,N'�鿴',1,0,0,1)
GO
INSERT INTO DBO.Base_ModulePermission ([ModuleID] ,[PermissionTitle] ,[PermissionValue] ,[Nullity] ,[StateFlag] ,[ParentID])
VALUES (405,N'����',2,0,0,1)
GO
INSERT INTO DBO.Base_ModulePermission ([ModuleID] ,[PermissionTitle] ,[PermissionValue] ,[Nullity] ,[StateFlag] ,[ParentID])
VALUES (405,N'�޸�',4,0,0,1)
GO
INSERT INTO DBO.Base_ModulePermission ([ModuleID] ,[PermissionTitle] ,[PermissionValue] ,[Nullity] ,[StateFlag] ,[ParentID])
VALUES (405,N'ɾ��',8,0,0,1)
GO
