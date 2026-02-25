package org.ngcvfb.inventorymanagementapi.repository;

import org.ngcvfb.inventorymanagementapi.model.Product;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

public interface ProductRepository extends JpaRepository<Product, Long>{

    @Override
    @EntityGraph(attributePaths = {"category"})
    Page<Product> findAll(Pageable pageable);

    @Query("select p from Product p left join fetch p.category where lower(p.name) like lower(concat('%', :q, '%')) or lower(p.sku) like lower(concat('%', :q, '%'))")
    Page<Product> searchByQ(@Param("q") String q, Pageable pageable);

    @Query("select coalesce(sum(p.currentStock), 0) from Product p")
    Long sumCurrentStock();

    @Query("select coalesce(sum(p.price * p.currentStock), 0) from Product p")
    BigDecimal sumPriceTimesStock();

    Optional<Product> findBySku(String sku);

    @Query("select p from Product p left join fetch p.category where p.category.id = :categoryId")
    Page<Product> findByCategoryId(@Param("categoryId") Long categoryId, Pageable pageable);

    @Query("select p from Product p left join fetch p.category where p.category.id = :catId and (lower(p.name) like lower(concat('%', :q, '%')) or lower(p.sku) like lower(concat('%', :q, '%')))")
    Page<Product> searchByQAndCategory(@Param("q") String q, @Param("catId") Long categoryId, Pageable pageable);

    @Query("SELECT COALESCE(SUM(p.currentStock), 0) FROM Product p WHERE p.id IN :ids")
    Long sumCurrentStockByIds(@Param("ids") List<Long> ids);

    @Query("SELECT COALESCE(SUM(p.currentStock * p.price), 0) FROM Product p WHERE p.id IN :ids")
    BigDecimal sumPriceTimesStockByIds(@Param("ids") List<Long> ids);

    List<Product> findByCurrentStockLessThanOrderByCurrentStockAsc(long threshold);
}
