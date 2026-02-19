package it.atlantica.validationhandler.validation;

import jakarta.validation.ConstraintValidator;
import jakarta.validation.ConstraintValidatorContext;
import org.apache.tika.Tika;
import org.springframework.http.InvalidMediaTypeException;
import org.springframework.http.MediaType;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;

import static java.util.Arrays.asList;

public class ContentTypeConstraintValidator implements ConstraintValidator<ContentType, MultipartFile> {

    private List<MediaType> mediaTypes;

    @Override
    public void initialize(final ContentType constraintAnnotation) {
        final String[] types = constraintAnnotation.value();
        mediaTypes = MediaType.parseMediaTypes(asList(types));
    }

    @Override
    public boolean isValid(final MultipartFile value, final ConstraintValidatorContext context) {
        if (value == null || value.isEmpty()) {
            return true;
        }

        final String contentType = value.getContentType();
        if (contentType == null) {
            return false;
        }

        try {
            final MediaType mediaType = MediaType.parseMediaType(contentType);

            final Tika tika = new Tika();
            final String detectedType = tika.detect(value.getInputStream());
            final MediaType detectedMediaType = MediaType.parseMediaType(detectedType);

            return mediaType.isConcrete() && mediaType.isCompatibleWith(detectedMediaType)
                    && mediaTypes.stream().anyMatch(mediaType::isCompatibleWith);

        } catch (InvalidMediaTypeException | IOException e) {
            return false;
        }
    }

}
