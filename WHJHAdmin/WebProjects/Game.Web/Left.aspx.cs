﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using Game.Facade;
using Game.Entity.PlatformManager;

namespace Game.Web
{
    public partial class Left : System.Web.UI.Page
    {
        /// <summary>
        /// 菜单数据集
        /// </summary>
        DataSet ds = null;

        /// <summary>
        /// 页面初始化
        /// </summary>
        protected override void OnInit(EventArgs e)
        {
            LoginUser userExt = Fetch.GetLoginUser();
            if(userExt == null || userExt.UserID < 0)
            {
                Fetch.Redirect("/Login.aspx");
                return;
            }

            ds = FacadeManage.aidePlatformManagerFacade.GetMenuByUserId(userExt.UserID);
            LeftMenu.DataSource = ds.Tables[0];
            LeftMenu.DataBind();
        }

        /// <summary>
        /// 绑定菜单
        /// </summary>
        protected void LeftMenu_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            DataTable dt = ds.Tables[1];
            DataTable dtNew = dt.Clone();
            int moduleID = Convert.ToInt32(DataBinder.Eval(e.Item.DataItem, "ModuleID"));
            DataRow[] drArray = dt.Select("ParentID=" + moduleID);

            //复制
            foreach(DataRow dr in drArray)
            {
                DataRow drNew = dtNew.NewRow();
                drNew.ItemArray = dr.ItemArray;
                dtNew.Rows.Add(drNew);
            }

            Repeater leftSubID = (Repeater)e.Item.FindControl("LeftMenu_Sub");
            leftSubID.DataSource = dtNew;
            leftSubID.DataBind();
        }

    }
}