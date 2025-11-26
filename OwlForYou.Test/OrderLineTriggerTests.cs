using Microsoft.VisualStudio.TestTools.UnitTesting;
using OwlForYou.Test.Models.cs;
using System;
using System.Linq;

namespace OwlForYou.Tests
{
    [TestClass]
    public class OrderLineTriggerTests
    {
        [TestMethod]
        public void Trigger_Calcule_Bien_La_Ligne_Commande()
        {
            using var ctx = new OwlForYouContext();

            var order = new Order
            {
                OrderDate = new DateTime(2020, 9, 21)
            };
            ctx.Orders.Add(order);
            ctx.SaveChanges();

            var line = new OrderLine
            {
                OrderId = order.OrderId,
                ProductId = 5,  
                Quantity = 2
            };
            ctx.OrderLines.Add(line);
            ctx.SaveChanges(); 

           
            ctx.Entry(line).Reload();

            Assert.AreEqual(30.00m, line.UnitPrice, "UnitPrice doit être 30.00");
            Assert.AreEqual(0.30m, line.AppliedDiscount, "AppliedDiscount doit être 0.30");

            var totalAttendu = 30.00m * (1 - 0.30m) * 2; // 42
            Assert.AreEqual(totalAttendu, line.TotalLine, "TotalLine doit être 42.00");
        }

    }
}
