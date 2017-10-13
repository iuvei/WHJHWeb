﻿using System;
using System.Collections;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.IO;
using System.Net;
using System.Text;
using System.Web.Script.Serialization;
using Game.Entity.Treasure;
using Game.Facade;
using Game.Utils;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace Game.Web.Helper
{
    /// <summary>
    /// 零钱支付
    /// </summary>
    // ReSharper disable once InconsistentNaming
    public static class LQPay
    {
        public static class Config
        {
            public static string PrePayUrl = ApplicationSettings.Get("LQPayPreUrl");
            public static string PayUrl = ApplicationSettings.Get("LQPayUrl");
            public static string CompId = ApplicationSettings.Get("LQPayComID"); //商户编号 web.config LQPayComID
            public static string ProdId = ApplicationSettings.Get("LQPayProdID"); //产品编号 web.config  LQPayProdID
            public static string Key = ApplicationSettings.Get("LQPayKey"); //商户密钥 web.config  LQPayKey
        }

        public static string GetPayPackage(OnLinePayOrder onlineOrder, string uuid, string userid, string type,
            string authority)
        {
            string domain = string.IsNullOrEmpty(AppConfig.FrontSiteDomain) ? authority : AppConfig.FrontSiteDomain;
            string notifyUrl = "http://" + domain + "/Notify/LqPay.aspx";
            string returnUrl = type == "IOS" ? "schame://" : "";
            PayContent content = new PayContent()
            {
                code = "001",
                comment = onlineOrder.Diamond + "颗 钻石",
                name = "钻石",
                price = ((onlineOrder.Amount / onlineOrder.Diamond) * 100).ToString("F0"),
                quality = onlineOrder.Diamond.ToString(),
                realMoney = (onlineOrder.Amount * 100).ToString("F0"),
                rebateMoney = "0",
                totalMoney = (onlineOrder.Amount * 100).ToString("F0"),
                showUrl = "",
                unit = "颗"
            };
            Request request = new Request(onlineOrder.OrderID, notifyUrl, returnUrl);
            request.AddParamValue("uuid", uuid);
            request.AddParamValue("user_id", userid);
            request.AddParamValue("total_money", (onlineOrder.Amount * 100).ToString("F0"));
            request.AddParamValue("rebate_money", "0");
            request.AddParamValue("real_money", (onlineOrder.Amount * 100).ToString("F0"));
            request.AddParamValue("pay_content", "[" + content + "]");
            string result = Get(request.ToString("prepay"));
            JObject jObject = (JObject)JsonConvert.DeserializeObject(result);
            if (jObject["ret_code"] != null && (string) jObject["ret_code"] != "0000")
            {
                Log4Net.WriteInfoLog(result);
            }
            return "";
        }

        public static string Get(string url)
        {
            GC.Collect();
            string result;

            HttpWebRequest request = null;
            HttpWebResponse response = null;

            //请求url以获取数据
            try
            {
                //设置最大连接数
                ServicePointManager.DefaultConnectionLimit = 200;

                request = (HttpWebRequest) WebRequest.Create(url);

                request.Method = "GET";

                //获取服务器返回
                response = (HttpWebResponse) request.GetResponse();

                //获取HTTP返回数据
                // ReSharper disable once AssignNullToNotNullAttribute
                StreamReader sr = new StreamReader(stream: response.GetResponseStream(), encoding: Encoding.UTF8);
                result = sr.ReadToEnd().Trim();
                sr.Close();
            }
            finally
            {
                //关闭连接和流
                response?.Close();
                request?.Abort();
            }
            return result;
        }

        public class Request
        {
            private readonly SortedDictionary<string, object> _param;
            private readonly ArrayList _index;

            public Request(string orderId, string notifyUrl, string returnUrl = "")
            {
                _index = new ArrayList
                {
                    "comp_id",
                    "prod_id",
                    "po_num",
                    "version",
                    "sourceType",
                    "notify_url",
                    "return_url",
                    "time_stamp"
                };
                _param = new SortedDictionary<string, object>
                {
                    {"comp_id", Config.CompId},
                    {"prod_id", Config.ProdId},
                    {"po_num", orderId},
                    {"version", "1.0"},
                    {"sourceType", "H5"},
                    {"notify_url", notifyUrl},
                    {"return_url", returnUrl},
                    {"time_stamp", DateTime.Now.ToString("yyyyMMddHHmmss")}
                };
            }

            public string Param
            {
                get
                {
                    string p = "";
                    foreach (object t in _index)
                    {
                        object value;
                        if (!_param.TryGetValue(t.ToString(), out value)) continue;
                        if (value != null)
                        {
                            p += value + "|";
                        }
                    }
                    return p.Substring(0, p.Length - 1);
                }
            }

            public string Sign
            {
                get { return Md5SignUtil.CreateSign(Param); }
            }

            /// <summary>
            /// 修改内部参数值方法（只有存在才生效）
            /// </summary>
            /// <param name="key"></param>
            /// <param name="value"></param>
            public void SetParamValue(string key, object value)
            {
                if (_param.ContainsKey(key))
                {
                    _param[key] = value;
                }
            }

            /// <summary>
            /// 添加内部参数方法（存在则修改）
            /// </summary>
            /// <param name="key"></param>
            /// <param name="value"></param>
            public void AddParamValue(string key, object value)
            {
                if (_param.ContainsKey(key))
                {
                    SetParamValue(key, value);
                }
                else
                {
                    _index.Add(key);
                    _param.Add(key, value);
                }
            }

            /// <summary>
            /// 重写ToString 方法为 JSON.stringify()
            /// </summary>
            /// <returns></returns>
            public string ToString(string type)
            {
                return (type=="prepay"? Config.PrePayUrl:Config.PayUrl) + "?param=" + Param + "&sign=" + Sign;
            }
        }

        [Serializable]
        public class PayContent
        {
            // ReSharper disable once InconsistentNaming
            public string code { get; set; }
            // ReSharper disable once InconsistentNaming
            public string comment { get; set; }
            // ReSharper disable once InconsistentNaming
            public string name { get; set; }
            // ReSharper disable once InconsistentNaming
            public string price { get; set; }
            // ReSharper disable once InconsistentNaming
            public string quality { get; set; }
            // ReSharper disable once InconsistentNaming
            public string realMoney { get; set; }
            // ReSharper disable once InconsistentNaming
            public string rebateMoney { get; set; }
            // ReSharper disable once InconsistentNaming
            public string totalMoney { get; set; }
            // ReSharper disable once InconsistentNaming
            public string showUrl { get; set; }
            // ReSharper disable once InconsistentNaming
            public string unit { get; set; }

            public override string ToString()
            {
                return new JavaScriptSerializer().Serialize(this);
            }
        }

        /// <summary>
        /// 支付回调实体
        /// </summary>
        public class Notify
        {
            public Notify()
            {
                Param = "";
                Sign = "";
                ExtraParam = new ExtraParam();
                ExtraSign = "";
            }

            public Notify(NameValueCollection param)
            {
                if (param["param"] != null) Param = param["param"];
                if (param["sign"] != null) Sign = param["sign"];
                if (param["extra_param"] != null) ExtraParam = new ExtraParam(param["extra_param"]);
                if (param["extra_sign"] != null) ExtraSign = param["extra_sign"];
            }

            /// <summary>
            /// 主要参数
            /// </summary>
            public string Param { get; set; }

            /// <summary>
            /// 主要参数签名
            /// </summary>
            public string Sign { get; set; }

            /// <summary>
            /// 扩展参数签名
            /// </summary>
            public string ExtraSign { get; set; }

            /// <summary>
            /// 扩展参数
            /// </summary>
            public ExtraParam ExtraParam { get; set; }

            /// <summary>
            /// 主要参数验证
            /// </summary>
            public bool ParamChecked => Md5SignUtil.CheckSign(Param, Sign);

            /// <summary>
            /// 扩展参数验证
            /// </summary>
            public bool ExtraParamChecked => Md5SignUtil.CheckSign(ExtraParam.ToString(), Sign);

            /// <summary>
            /// 总体验证通过 return (bool) 主要参数验证通过 && 次要参数验证通过 && 商户编号和产品编号对应 
            /// </summary>
            public bool IsChecked => ParamChecked && ExtraParamChecked && ExtraParam.comp_id == Config.CompId &&
                                     ExtraParam.prod_id == Config.ProdId;
        }

        /// <summary>
        /// 扩展参数实体类
        /// </summary>
        public class ExtraParam
        {
            /// <summary>
            /// 初始化构造
            /// </summary>
            public ExtraParam()
            {
                comp_id = "";
                prod_id = "";
                money = "";
                out_trade_no = "";
                sign_type = "";
                notify_time = "";
            }

            /// <summary>
            /// 从JSON字符串转为实体
            /// </summary>
            /// <param name="json"></param>
            public ExtraParam(string json)
            {
                new JavaScriptSerializer().Deserialize<ExtraParam>(json);
            }

            /// <summary>
            /// 商户编号
            /// </summary>
            // ReSharper disable once InconsistentNaming
            public string comp_id { get; set; }

            /// <summary>
            /// 商品编号
            /// </summary>
            // ReSharper disable once InconsistentNaming
            public string prod_id { get; set; }

            /// <summary>
            /// 金额,单位为分
            /// </summary>
            // ReSharper disable once InconsistentNaming
            public string money { get; set; }

            /// <summary>
            /// 外单号，即OrderID
            /// </summary>
            // ReSharper disable once InconsistentNaming
            public string out_trade_no { get; set; }

            /// <summary>
            /// 签名类型
            /// </summary>
            // ReSharper disable once InconsistentNaming
            public string sign_type { get; set; }

            /// <summary>
            /// 通知时间 yyyyMMddHHmmss
            /// </summary>
            // ReSharper disable once InconsistentNaming
            public string notify_time { get; set; }

            /// <summary>
            /// 重写ToString 方法为 JSON.stringify()
            /// </summary>
            /// <returns></returns>
            public override string ToString()
            {
                return new JavaScriptSerializer().Serialize(this);
            }
        }

        public static class Md5SignUtil
        {
            /**
             * md5的签名检查
             */
            public static bool CheckSign(string content, string checkSign)
            {
                content = content + "|" + Config.Key;
                string sign = Utility.MD5(content).ToUpper();
                return sign.Equals(checkSign);
            }

            /**
             * 生成签名
             */
            public static string CreateSign(string content)
            {
                content = content + "|" + Config.Key;
                string sign = Utility.MD5(content).ToUpper();
                return sign;
            }
        }
    }
}