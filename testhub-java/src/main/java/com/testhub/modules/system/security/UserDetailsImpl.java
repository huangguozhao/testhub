package com.testhub.modules.system.security;

import com.testhub.modules.system.domain.User;
import lombok.Data;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

/**
 * 用户详情实现类
 */
@Data
public class UserDetailsImpl implements UserDetails {

    private Long id;
    private String username;
    private String password;
    private String email;
    private String status;
    private String roleName;
    private Integer isSuperuser;
    private Integer isStaff;
    private Collection<? extends GrantedAuthority> authorities;

    public UserDetailsImpl() {
    }

    public UserDetailsImpl(User user) {
        this.id = user.getId();
        this.username = user.getUsername();
        this.password = user.getPassword();
        this.email = user.getEmail();
        this.status = user.getStatus();
        this.roleName = user.getRoleName();
        this.isSuperuser = user.getIsSuperuser();
        this.isStaff = user.getIsStaff();
        this.authorities = loadAuthorities(user);
    }

    public UserDetailsImpl(Long id, String username, String password, String email, String status, String roleName, Integer isSuperuser, Integer isStaff) {
        this.id = id;
        this.username = username;
        this.password = password;
        this.email = email;
        this.status = status;
        this.roleName = roleName;
        this.isSuperuser = isSuperuser;
        this.isStaff = isStaff;
    }

    /**
     * 根据用户角色加载权限
     */
    private Collection<? extends GrantedAuthority> loadAuthorities(User user) {
        List<GrantedAuthority> authorities = new ArrayList<>();

        // 超级管理员拥有所有权限
        if (user.getIsSuperuser() != null && user.getIsSuperuser() == 1) {
            authorities.add(new SimpleGrantedAuthority("ROLE_SUPERUSER"));
            authorities.add(new SimpleGrantedAuthority("ROLE_ADMIN"));
            authorities.add(new SimpleGrantedAuthority("ROLE_USER"));
            return authorities;
        }

        // 管理员
        if ("ADMIN".equals(user.getRoleName())) {
            authorities.add(new SimpleGrantedAuthority("ROLE_ADMIN"));
        }

        // 工作人员（可以登录管理后台）
        if (user.getIsStaff() != null && user.getIsStaff() == 1) {
            authorities.add(new SimpleGrantedAuthority("ROLE_STAFF"));
        }

        // 普通用户
        authorities.add(new SimpleGrantedAuthority("ROLE_USER"));

        return authorities;
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return authorities;
    }

    @Override
    public String getPassword() {
        return password;
    }

    @Override
    public String getUsername() {
        return username;
    }

    @Override
    public boolean isAccountNonExpired() {
        return true;
    }

    @Override
    public boolean isAccountNonLocked() {
        return "enabled".equals(status);
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return true;
    }

    @Override
    public boolean isEnabled() {
        return "enabled".equals(status);
    }

    /**
     * 判断是否是超级管理员
     */
    public boolean isSuperuser() {
        return isSuperuser != null && isSuperuser == 1;
    }

    /**
     * 判断是否是管理员
     */
    public boolean isAdmin() {
        return isSuperuser() || "ADMIN".equals(roleName);
    }

    /**
     * 判断是否可以登录管理后台
     */
    public boolean isStaff() {
        return isStaff != null && isStaff == 1;
    }
}