package com.example.lab;

import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import java.util.List;

@Stateless
public class AuthorService
{
    @PersistenceContext(unitName = "labPU")
    private EntityManager em;

    // поиск всех авторов
    public List<Author> findAll() { return em.createQuery("select a from Author a order by a.id", Author.class).getResultList(); }

    // поиск автора по ID
    public Author find(Long id) { return em.find(Author.class, id); }

    // добавить нового автора
    public void create(Author a) { em.persist(a); }

    // обновить данные автора
    public Author update(Author a) { return em.merge(a); }

    // удалить автора
    public void delete(Long id) {
        Author a = em.find(Author.class, id);
        if (a != null) em.remove(a);
    }
}
