package orezybsk.aws.sample.webapp.entity;

import org.seasar.doma.Column;
import org.seasar.doma.Entity;
import org.seasar.doma.GeneratedValue;
import org.seasar.doma.GenerationType;
import org.seasar.doma.Id;
import org.seasar.doma.Table;

/**
 * 
 */
@Entity
@Table(name = "user_role")
public class UserRole {

    /**  */
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "role_id")
    Long roleId;

    /**  */
    @Column(name = "email")
    String email;

    /**  */
    @Column(name = "role")
    String role;

    /** 
     * Returns the roleId.
     * 
     * @return the roleId
     */
    public Long getRoleId() {
        return roleId;
    }

    /** 
     * Sets the roleId.
     * 
     * @param roleId the roleId
     */
    public void setRoleId(Long roleId) {
        this.roleId = roleId;
    }

    /** 
     * Returns the email.
     * 
     * @return the email
     */
    public String getEmail() {
        return email;
    }

    /** 
     * Sets the email.
     * 
     * @param email the email
     */
    public void setEmail(String email) {
        this.email = email;
    }

    /** 
     * Returns the role.
     * 
     * @return the role
     */
    public String getRole() {
        return role;
    }

    /** 
     * Sets the role.
     * 
     * @param role the role
     */
    public void setRole(String role) {
        this.role = role;
    }
}