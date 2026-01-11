package com.example.lab;

import jakarta.annotation.PostConstruct;
import jakarta.ejb.EJB;
import jakarta.faces.view.ViewScoped;
import jakarta.inject.Named;

import java.io.Serializable;
import java.util.List;

@Named
@ViewScoped
public class BookBean implements Serializable {

    @EJB
    private BookService bookService;

    @EJB
    private AuthorService authorService;

    private List<Book> books;
    private List<Author> authors;

    private Book form;

    // id книги приходит параметром в URL: book-form.xhtml?id=5
    private Long id;

    // выбранный автор в форме
    private Long authorId;

    @PostConstruct
    public void init() {
        books = bookService.findAll();
        authors = authorService.findAll();
        form = new Book();
    }

    // вызывается на book-form.xhtml через f:viewAction
    public void load() {
        // authors нужны для выпадающего списка
        authors = authorService.findAll();

        if (id != null) {
            Book existing = bookService.find(id);
            form = (existing != null) ? existing : new Book();
            authorId = (form.getAuthor() != null) ? form.getAuthor().getId() : null;
        } else {
            form = new Book();
            authorId = null;
        }
    }

    public String createNew() { return "book-form.xhtml?faces-redirect=true"; }

    public String edit(Long id) { return "book-form.xhtml?faces-redirect=true&id=" + id; }

    public String save() {
        if (authorId != null) {
            Author a = authorService.find(authorId);
            form.setAuthor(a);
        }

        if (form.getId() == null) bookService.create(form);
        else bookService.update(form);

        return "books.xhtml?faces-redirect=true";
    }

    public String delete(Long id) {
        bookService.delete(id);
        return "books.xhtml?faces-redirect=true";
    }

    public List<Book> getBooks() { return books; }
    public List<Author> getAuthors() { return authors; }

    public Book getForm() { return form; }
    public void setForm(Book form) { this.form = form; }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getAuthorId() { return authorId; }
    public void setAuthorId(Long authorId) { this.authorId = authorId; }
}
