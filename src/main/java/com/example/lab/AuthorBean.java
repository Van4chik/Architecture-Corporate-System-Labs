package com.example.lab;

import jakarta.annotation.PostConstruct;
import jakarta.ejb.EJB;
import jakarta.faces.view.ViewScoped;
import jakarta.inject.Named;

import java.io.Serializable;
import java.util.List;

@Named
@ViewScoped
public class AuthorBean implements Serializable {

    @EJB
    private AuthorService authorService;

    private List<Author> authors;

    private Author form;

    // id приходит параметром в URL: author-form.xhtml?id=123
    private Long id;

    @PostConstruct
    public void init() {
        authors = authorService.findAll();
        form = new Author();
    }

    // вызывается на author-form.xhtml через f:viewAction
    public void load() {
        if (id != null) {
            Author existing = authorService.find(id);
            form = (existing != null) ? existing : new Author();
        } else {
            form = new Author();
        }
    }

    public String createNew() { return "author-form.xhtml?faces-redirect=true"; }

    public String edit(Long id) { return "author-form.xhtml?faces-redirect=true&id=" + id; }

    public String save() {
        if (form.getId() == null) authorService.create(form);
        else authorService.update(form);

        return "authors.xhtml?faces-redirect=true";
    }

    public String delete(Long id) {
        authorService.delete(id);
        return "authors.xhtml?faces-redirect=true";
    }

    public List<Author> getAuthors() { return authors; }

    public Author getForm() { return form; }
    public void setForm(Author form) { this.form = form; }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
}
