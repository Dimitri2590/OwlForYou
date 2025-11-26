using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using System.Data;

namespace OwlForYou.Tests
{
    [TestClass]
    public class StoredProcedureTests
    {
        [TestMethod]
        public void ReductionOk()
        {
            using var ctx = new OwlForYouContext();
            using var cn = (SqlConnection)ctx.Database.GetDbConnection();
            cn.Open();

            using var cmd = new SqlCommand("[OwlForYou2].usp_GetDiscountForProductOnDate", cn)
            {
                CommandType = CommandType.StoredProcedure
            };

            cmd.Parameters.AddWithValue("@ProductId", 5);
            cmd.Parameters.AddWithValue("@OrderDate", new DateTime(2020, 9, 21));

            var discountParam = new SqlParameter("@Discount", SqlDbType.Decimal)
            {
                Precision = 5,
                Scale = 2,
                Direction = ParameterDirection.Output
            };
            cmd.Parameters.Add(discountParam);

            cmd.ExecuteNonQuery();

            var discount = (decimal)discountParam.Value;

           
            Assert.AreEqual(0.30m, discount, "La procédure doit renvoyer 0.30 (30%).");
        }
    }
}
