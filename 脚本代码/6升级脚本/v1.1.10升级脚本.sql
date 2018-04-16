USE [WHJHNativeWebDB]
GO

-- v1.1.10 ����վ�����ã�����վվ�����õ�˵�����ֶΡ�
UPDATE ConfigInfo SET ConfigString = N'����˵��
�ֶ�1����վ��ά���ַ
�ֶ�2����վͼƬ��������ַ
�ֶ�3����վǰ̨��������ַ
�ֶ�4��H5��Ϸ��������ַ
�ֶ�5��������վ������IP
�ֶ�8����վǰ̨�ײ�����',Field5 = N'/Card'
WHERE ConfigKey = N'WebSiteConfig'

-- v1.1.10 �½�������֤��Ϣ��
IF EXISTS (SELECT 1
FROM [DBO].SYSObjects
WHERE ID = OBJECT_ID(N'[dbo].[AgentTokenInfo]') AND OBJECTPROPERTY(ID,'IsTable')=1 )
BEGIN
  DROP TABLE [dbo].[AgentTokenInfo]
END
GO

/****** Object:  Table [dbo].[AgentTokenInfo]    Script Date: 2018/3/16 16:32:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[AgentTokenInfo](
	[UserID] [int] NOT NULL,
	[AgentID] [int] NOT NULL,
	[Token] [nvarchar](64) NOT NULL,
	[ExpirtAt] [datetime] NOT NULL,
 CONSTRAINT [PK_AgentTokenInfo] PRIMARY KEY CLUSTERED
(
	[UserID] ASC,
	[AgentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[AgentTokenInfo] ADD  CONSTRAINT [DF_AgentTokenInfo_UserID]  DEFAULT ((0)) FOR [UserID]
GO

ALTER TABLE [dbo].[AgentTokenInfo] ADD  CONSTRAINT [DF_AgentTokenInfo_AgentID]  DEFAULT ((0)) FOR [AgentID]
GO

ALTER TABLE [dbo].[AgentTokenInfo] ADD  CONSTRAINT [DF_AgentTokenInfo_Token]  DEFAULT (N'') FOR [Token]
GO

ALTER TABLE [dbo].[AgentTokenInfo] ADD  CONSTRAINT [DF_AgentTokenInfo_ExpirtAt]  DEFAULT (getdate()+(1)) FOR [ExpirtAt]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'�û���ʶ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AgentTokenInfo', @level2type=N'COLUMN',@level2name=N'UserID'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'�����ʶ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AgentTokenInfo', @level2type=N'COLUMN',@level2name=N'AgentID'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'��֤����SHA256��' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AgentTokenInfo', @level2type=N'COLUMN',@level2name=N'Token'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'����ʱ��' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AgentTokenInfo', @level2type=N'COLUMN',@level2name=N'ExpirtAt'
GO


-- v1.1.10 �����̨��¼���ֻ���+��ȫ���룩�洢
----------------------------------------------------------------------------------------------------
-- ��Ȩ��2018
-- ʱ�䣺2018-03-16
-- ��;�������̨��¼���ֻ���+��ȫ���룩
----------------------------------------------------------------------------------------------------

USE WHJHAccountsDB
GO

IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'[dbo].NET_PW_AgentAccountsLogin_MP') and OBJECTPROPERTY(ID, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].NET_PW_AgentAccountsLogin_MP
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_NULLS ON
GO

----------------------------------------------------------------------------------------------------

-- �ʺŵ�¼
CREATE PROCEDURE NET_PW_AgentAccountsLogin_MP
	@strMobile NVARCHAR(11),					-- �ֻ�����
	@strPassword NVARCHAR(32),					-- ��ȫ����
	@strClientIP NVARCHAR(15),					-- ���ӵ�ַ
	@strErrorDescribe	NVARCHAR(127) OUTPUT	-- �����Ϣ
WITH ENCRYPTION AS

-- ��������
SET NOCOUNT ON

-- ������Ϣ
DECLARE @UserID INT
DECLARE @FaceID INT
DECLARE @Accounts NVARCHAR(31)
DECLARE @Nickname NVARCHAR(31)
DECLARE @UnderWrite NVARCHAR(63)
DECLARE @AgentID INT
DECLARE @Nullity BIT
DECLARE @StunDown BIT

-- ��չ��Ϣ
DECLARE @GameID INT
DECLARE @CustomID INT
DECLARE @Gender TINYINT
DECLARE @Experience INT
DECLARE @Loveliness INT
DECLARE @MemberOrder INT
DECLARE @MemberOverDate DATETIME
DECLARE @CustomFaceVer TINYINT
DECLARE @SpreaderID INT
DECLARE @PlayTimeCount INT
DECLARE @AgentNullity TINYINT

-- ��������
DECLARE @EnjoinLogon AS INT
DECLARE @StatusString NVARCHAR(127)

-- ִ���߼�
BEGIN
	-- ϵͳ��ͣ
	SELECT @EnjoinLogon=StatusValue,@StatusString=StatusString FROM SystemStatusInfo WITH(NOLOCK) WHERE StatusName=N'EnjoinLogon'
	IF @EnjoinLogon=1
	BEGIN
		SELECT @strErrorDescribe=@StatusString
		RETURN 1001
	END

	-- Ч���ַ
	SELECT @EnjoinLogon=EnjoinLogon FROM ConfineAddress WITH(NOLOCK) WHERE AddrString=@strClientIP AND (EnjoinOverDate>GETDATE() OR EnjoinOverDate IS NULL)
	IF @EnjoinLogon=1
	BEGIN
		SET @strErrorDescribe=N'��Ǹ��ϵͳ��ֹ�������ڵ� IP ��ַ�ĵ�¼���ܣ�'
		RETURN 1002
	END

  -- ��ѯ����
  SELECT @AgentID = AgentID,@UserID = UserID,@AgentNullity=Nullity FROM AccountsAgentInfo WITH(NOLOCK) WHERE ContactPhone = @strMobile AND [Password] = @strPassword

  IF @UserID IS NULL
	BEGIN
		SET @strErrorDescribe=N'��Ǹ�������ʺŲ����ڣ�'
		RETURN 1002
	END

	-- ��ѯ�û�
	SELECT @GameID=GameID, @Accounts=Accounts, @Nickname=Nickname, @UnderWrite=UnderWrite, @FaceID=FaceID,@CustomID=CustomID,
		@Gender=Gender, @Nullity=Nullity, @StunDown=StunDown, @SpreaderID=SpreaderID,@PlayTimeCount=PlayTimeCount,@AgentID=AgentID
	FROM AccountsInfo WITH(NOLOCK) WHERE UserID=@UserID

	-- �ʺŽ�ֹ
	IF @Nullity=1
	BEGIN
		SET @strErrorDescribe=N'��Ǹ�������ʺ��Ѷ��ᣡ'
		RETURN 1003
	END

	-- �ʺŹر�
	IF @StunDown=1
	BEGIN
		SET @strErrorDescribe=N'��Ǹ�������ʺ��ѿ�����ȫ�رգ�'
		RETURN 1004
	END

  -- �����ж�
	IF @AgentID IS NULL
	BEGIN
		SET @strErrorDescribe=N'��Ǹ�������ʺ�Ϊ�Ǵ����̣�'
		RETURN 2001
	END
	IF @AgentNullity IS NULL
	BEGIN
		SET @strErrorDescribe=N'��Ǹ�������ʺ�Ϊ�Ǵ����̣�'
		RETURN 2001
	END
	IF @AgentNullity=1
	BEGIN
		SET @strErrorDescribe=N'��Ǹ�����Ĵ����ʺ��Ѷ��ᣡ'
		RETURN 2002
	END

	-- ������Ϣ
	UPDATE AccountsInfo SET WebLogonTimes=WebLogonTimes+1,LastLogonDate=GETDATE(),LastLogonIP=@strClientIP WHERE UserID=@UserID

	-- ��¼��־
	DECLARE @DateID INT
	SET @DateID=CAST(CAST(GETDATE() AS FLOAT) AS INT)
	UPDATE SystemStreamInfo SET WebLogonSuccess=WebLogonSuccess+1 WHERE DateID=@DateID
	IF @@ROWCOUNT=0 INSERT SystemStreamInfo (DateID, WebLogonSuccess) VALUES (@DateID, 1)

	-- �������
	SELECT @UserID AS UserID, @GameID AS GameID, @Accounts AS Accounts, @Nickname AS Nickname,@UnderWrite AS UnderWrite, @FaceID AS FaceID, @CustomID AS CustomID,
		@Gender AS Gender,@AgentID AS AgentID
END

RETURN 0
GO


-- 1.1.10 ��������ֵ���������İ汾
USE WHJHAccountsDB
GO

INSERT DBO.SystemStatusInfo (StatusName,StatusValue,StatusString,StatusTip,StatusDescription,SortID)
VALUES (N'AgentHomeVersion',1, N'�����̨�İ汾�ţ����л����Ϻ�̨',N'�����̨�汾',N'��ֵ��1-�ϰ汾������̨��2-�°汾������̨',9999)
GO
