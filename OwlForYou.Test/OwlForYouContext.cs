using Microsoft.EntityFrameworkCore;
using OwlForYou.Test.Models.cs;

namespace OwlForYou.Tests
{
    public class OwlForYouContext : DbContext
    {
        public DbSet<Order> Orders => Set<Order>();
        public DbSet<OrderLine> OrderLines => Set<OrderLine>();

        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            optionsBuilder.UseSqlServer(
                "Server=dim2026.database.windows.net;Database=Exercice;User Id=dim;Password=!Carodidi1766;Encrypt=False;");
        }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.HasDefaultSchema("OwlForYou2");

            // Permet de définir la clé primaire d'Order 
            modelBuilder.Entity<Order>().ToTable("Orders", "OwlForYou2").HasKey(o => o.OrderId);

            // Permet de définir la clé primaire d'OrderLine
            modelBuilder.Entity<OrderLine>().ToTable("OrderLines", "OwlForYou2").HasKey(ol => ol.LineId);

            modelBuilder.Entity<OrderLine>().ToTable("OrderLines", tb => tb.HasTrigger("Trg_CalculateOrderLine"));
        }
    }
}
