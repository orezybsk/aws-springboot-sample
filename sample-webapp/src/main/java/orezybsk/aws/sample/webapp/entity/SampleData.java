package orezybsk.aws.sample.webapp.entity;

import org.seasar.doma.Column;
import org.seasar.doma.Entity;
import org.seasar.doma.GeneratedValue;
import org.seasar.doma.GenerationType;
import org.seasar.doma.Id;
import org.seasar.doma.Table;

import java.io.Serializable;

/**
 * 
 */
@Entity
@Table(name = "sample_data")
public class SampleData implements Serializable {

    private static final long serialVersionUID = 617181738149089885L;

    /**  */
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    Long id;

    /**  */
    @Column(name = "name")
    String name;

    /**  */
    @Column(name = "age")
    Integer age;

    /** 
     * Returns the id.
     * 
     * @return the id
     */
    public Long getId() {
        return id;
    }

    /** 
     * Sets the id.
     * 
     * @param id the id
     */
    public void setId(Long id) {
        this.id = id;
    }

    /** 
     * Returns the name.
     * 
     * @return the name
     */
    public String getName() {
        return name;
    }

    /** 
     * Sets the name.
     * 
     * @param name the name
     */
    public void setName(String name) {
        this.name = name;
    }

    /** 
     * Returns the age.
     * 
     * @return the age
     */
    public Integer getAge() {
        return age;
    }

    /** 
     * Sets the age.
     * 
     * @param age the age
     */
    public void setAge(Integer age) {
        this.age = age;
    }
}