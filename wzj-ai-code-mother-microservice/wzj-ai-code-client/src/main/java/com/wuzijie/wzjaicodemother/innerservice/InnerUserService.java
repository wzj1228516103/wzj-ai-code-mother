package com.wuzijie.wzjaicodemother.innerservice;

import com.wuzijie.wzjaicodemother.exception.BusinessException;
import com.wuzijie.wzjaicodemother.exception.ErrorCode;
import com.wuzijie.wzjaicodemother.model.entity.User;
import com.wuzijie.wzjaicodemother.model.vo.LoginUserVO;
import com.wuzijie.wzjaicodemother.model.vo.UserVO;
import jakarta.servlet.http.HttpServletRequest;

import java.io.Serializable;
import java.util.Collection;
import java.util.List;

import static com.wuzijie.wzjaicodemother.constant.UserConstant.USER_LOGIN_STATE;

/**
 * 内部使用的用户服务
 */
public interface InnerUserService {

    List<User> listByIds(Collection<? extends Serializable> ids);

    User getById(Serializable id);

    UserVO getUserVO(User user);

    // 静态方法，避免跨服务调用
    static User getLoginUser(HttpServletRequest request) {
        if (request.getSession(false) == null) {
            throw new BusinessException(ErrorCode.NOT_LOGIN_ERROR);
        }
        Object loginState = request.getSession(false).getAttribute(USER_LOGIN_STATE);
        if (loginState instanceof User currentUser) {
            if (currentUser.getId() == null) {
                throw new BusinessException(ErrorCode.NOT_LOGIN_ERROR);
            }
            return currentUser;
        }
        if (loginState instanceof LoginUserVO loginUserVO) {
            if (loginUserVO.getId() == null) {
                throw new BusinessException(ErrorCode.NOT_LOGIN_ERROR);
            }
            User currentUser = new User();
            currentUser.setId(loginUserVO.getId());
            currentUser.setUserAccount(loginUserVO.getUserAccount());
            currentUser.setUserName(loginUserVO.getUserName());
            currentUser.setUserAvatar(loginUserVO.getUserAvatar());
            currentUser.setUserProfile(loginUserVO.getUserProfile());
            currentUser.setUserRole(loginUserVO.getUserRole());
            currentUser.setCreateTime(loginUserVO.getCreateTime());
            currentUser.setUpdateTime(loginUserVO.getUpdateTime());
            return currentUser;
        }
        throw new BusinessException(ErrorCode.NOT_LOGIN_ERROR);
    }
}