﻿<%@ Page Title="" Language="C#" MasterPageFile="~/Card/Site.Master" AutoEventWireup="true" CodeBehind="PresentRecord.aspx.cs" Inherits="Game.Web.Card.PresentRecord" %>

  <asp:Content ID="Content1" ContentPlaceHolderID="Css" runat="server">
    <link href="/Card/Css/record.css" rel="stylesheet" />
    <link href="/Card/Js/iscroll/pullup-refresh.css" rel="stylesheet" />
  </asp:Content>
  <asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <sd:Sidebar ID="sideTitle" runat="server" />
    <div class="ui-table-box">
      <form runat="server">
        <table class="ui-detail active">
          <thead id="thead">
            <tr>
              <th>赠送时间</th>
              <th>赠送 I D</th>
              <th>赠送（前）钻石</th>
              <th>赠送备注</th>
            </tr>
          </thead>
        </table>
        <div id="wrapper">
          <table class="ui-detail active">
            <tbody data-url="/Card/DataHandler.ashx?action=getpresentdiamondlist" id="list">
            </tbody>
          </table>
        </div>
      </form>
    </div>
    <script src="/Card/Js/iscroll/iscroll-probe.js" type="text/javascript"></script>
    <script src="/Card/Js/iscroll/pullup-refresh.js" type="text/javascript"></script>
    <script src="/Card/Js/iscroll/load.js"></script>
  </asp:Content>