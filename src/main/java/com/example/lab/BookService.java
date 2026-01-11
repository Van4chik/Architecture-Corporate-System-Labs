package com.example.lab;

import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import java.util.List;

@Stateless
public class BookService {

    @PersistenceContext(unitName = "labPU")
    private EntityManager em;

    // поиск всех книг
    public List<Book> findAll() { return em.createQuery("select b from Book b join fetch b.author order by b.id", Book.class).getResultList(); }

    // поиск книги по ID
    public Book find(Long id) { return em.find(Book.class, id); }

    // добавить новую книгу
    public void create(Book b) { em.persist(b); }

    // обновить данные книги
    public Book update(Book b) { return em.merge(b); }

    // удалить книгу
    public void delete(Long id) {
        Book b = em.find(Book.class, id);
        if (b != null) em.remove(b);
    }
}
