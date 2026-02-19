package it.atlantica.entity;


import it.atlantica.entity.keycloak.KeycloakRole;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "menu_items")
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class MenuItem {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column( length = 50)
    private String item;

    @Column(nullable = false, length = 100)
    private String label;

    @Column(length = 100)
    private String description;

    @ManyToOne
    @JoinColumn(name = "parent_id")
    private MenuItem parent;

    @Column(name = "visual_order", nullable = false,columnDefinition = "INTEGER DEFAULT 0")
    private int visualOrder = 0;

    @Column(length = 300)
    private String uri;


    @Column(length = 100)
    private String icon;

    @Column(name="visible")
    private boolean visible;

    @ManyToOne
    @JoinColumn(name = "role_id",nullable = false)
    private KeycloakRole role;
}